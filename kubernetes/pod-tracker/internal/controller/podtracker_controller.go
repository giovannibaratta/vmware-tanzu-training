/*
Copyright 2024.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package controller

import (
	"context"
	"fmt"

	"slices"

	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/handler"
	"sigs.k8s.io/controller-runtime/pkg/log"
	"sigs.k8s.io/controller-runtime/pkg/reconcile"

	podsv1alpha1 "github.com/giovannibaratta/vmware-tanzu-training/api/v1alpha1"
)

// RBAC permissions that must be assigned to the controller
// +kubebuilder:rbac:groups="",resources=pods,verbs=get;list;watch
// +kubebuilder:rbac:groups=pods.giovannibaratta.local,resources=podtrackers,verbs=get;list;watch;create;update;patch;delete
// +kubebuilder:rbac:groups=pods.giovannibaratta.local,resources=podtrackers/status,verbs=get;update;patch
// +kubebuilder:rbac:groups=pods.giovannibaratta.local,resources=podtrackers/finalizers,verbs=update

func (r *PodTrackerReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	logger := log.FromContext(ctx)

	podTracker := &podsv1alpha1.PodTracker{}

	// Fetch the current status of the PodTracker we are processing
	err := r.Get(ctx, req.NamespacedName, podTracker)
	if err != nil {
		if errors.IsNotFound(err) {
			logger.V(1).Info("PodTracker not found", "resource", req.NamespacedName)
			return ctrl.Result{}, nil
		}

		logger.Error(err, "Error while fetching pod tracker", "resource", req.NamespacedName)
		return ctrl.Result{}, err
	}

	logger.V(1).Info("Reconciling pod tracker", "podTracker", podTracker, "status", podTracker.Status)

	if isPodTrackerBeingDeleted(podTracker) {
		// Nothing to do
		logger.Info(fmt.Sprintf("Resource %s is being deleted. Skipping processing.", req.NamespacedName))
		return ctrl.Result{}, nil
	}

	// Fetch the status of pod that must be tracked. It is used to determine the initial (or the new) 
	// status of the pod tracker
	podToTrack := &corev1.Pod{}

	err = r.Get(ctx, types.NamespacedName{
		Namespace: podTracker.Spec.PodToTrack.Namespace,
		Name:      podTracker.Spec.PodToTrack.Name,
	}, podToTrack)

	// If the pod has not been found, we can still initializing the tracker. In all the other case
	// we throw the error
	if err != nil && !errors.IsNotFound(err) {
		// There was an error during fetch
		logger.Error(err, "Error while fetching tracked pod", "resource", fmt.Sprintf("%s/%s", podTracker.Spec.PodToTrack.Namespace, podTracker.Spec.PodToTrack.Name))
		return ctrl.Result{}, err
	}

	logger.V(1).Info("pod to track", "pod", podToTrack, "status", podToTrack.Status.Phase)

	updatedStatus := determinePodTrackerStatus(podTracker, podToTrack)

	logger.Info("Updating podTracker", "status", updatedStatus)
	podTracker.Status = updatedStatus
	err = r.Status().Update(ctx, podTracker)
	if err != nil {
		logger.Info("Failed to update podTracker", "resource", req.NamespacedName)
		return ctrl.Result{}, err
	}

	return ctrl.Result{}, nil
}

func isPodTrackerBeingDeleted(tracker *podsv1alpha1.PodTracker) bool {
	return !tracker.ObjectMeta.DeletionTimestamp.IsZero()
}

func determinePodTrackerStatus(tracker *podsv1alpha1.PodTracker, podToTrack *corev1.Pod) podsv1alpha1.PodTrackerStatus {
	if tracker.Status.PodStatus == "" {
		// The tracker has not been initialized yet
		return podsv1alpha1.PodTrackerStatus{
			PodStatus: podsv1alpha1.WaitingForPod,
		}
	}

	if tracker.Status.PodStatus == podsv1alpha1.PodTerminated {
		// The whole lifecycle of the pod has already been tracked. The job of the tracker is done.
		return tracker.Status
	}

	if tracker.Status.PodStatus == podsv1alpha1.PodReady {
		// We are actively tracking the pod
	
		if podToTrack == nil {
			// The pod does not exist anymore. There is nothing else to track. This might be a bug since a
			// graceful termination is expected.
			endTime := metav1.Now()
			executionTime := metav1.Duration{
				Duration: endTime.Sub(tracker.Status.StartTime.Time),
			}

			return podsv1alpha1.PodTrackerStatus{
				PodStatus:     podsv1alpha1.PodTerminated,
				StartTime:     tracker.Status.StartTime,
				EndTime:       endTime,
				ExecutionTime: executionTime,
			}
		}

		if slices.Contains([]corev1.PodPhase{corev1.PodSucceeded, corev1.PodFailed}, podToTrack.Status.Phase) {
			// The pod terminated the execution, we can stop tracking it
			endTime := metav1.Now()
			executionTime := metav1.Duration{
				Duration: endTime.Sub(tracker.Status.StartTime.Time),
			}

			return podsv1alpha1.PodTrackerStatus{
				PodStatus:     podsv1alpha1.PodTerminated,
				StartTime:     tracker.Status.StartTime,
				EndTime:       endTime,
				ExecutionTime: executionTime,
			}
		}

		// If pod state is running or unknown we do not update the tracker. If the pod is pending we
		// assume that this is a bug but we don't want to handle the error for now
		return tracker.Status
	}

	if tracker.Status.PodStatus == podsv1alpha1.WaitingForPod {
		// The tracker did not start to track the pod yet, if the pod is in the right status, 
		// we can start tracking it
		if podToTrack != nil && podToTrack.Status.Phase == corev1.PodRunning {
			// The pod terminated the execution, we can stop tracking it
			startTime := metav1.Now()

			return podsv1alpha1.PodTrackerStatus{
				PodStatus: podsv1alpha1.PodReady,
				StartTime: startTime,
			}
		}
	}

	return tracker.Status
}

// Configure the capabilities of the controller
func (r *PodTrackerReconciler) SetupWithManager(mgr ctrl.Manager) error {

	// In order to filter the results of a List operation, we have to instruct the controller to build
	// a local index. The index needs a unique key (trackerIndexKey) and a function that given a
	// object will extract the value for the given key.
	mgr.
		GetFieldIndexer().
		IndexField(context.Background(), &podsv1alpha1.PodTracker{}, trackerIndexKey, func(rawObj client.Object) []string {
			tracker := rawObj.(*podsv1alpha1.PodTracker)
			// In this case, the value of the index for a given object is the pair Namespace/Name of the pod
			// that must be tracked. This will allow us to identify all the pod tracker that must be reconciled
			// when the pod is updated.
			indexValue := fmt.Sprintf("%s/%s", tracker.Spec.PodToTrack.Namespace, tracker.Spec.PodToTrack.Name)
			return []string{indexValue}
		})

	// Instruct the controller to trigger the reconcile loop for objects of type PodTracker and to 
	// to watch updated for objects of type Pods.
	return ctrl.NewControllerManagedBy(mgr).
		For(&podsv1alpha1.PodTracker{}).
		Watches(
			&corev1.Pod{},
			handler.EnqueueRequestsFromMapFunc(r.findTrackersForPod),
		).
		Complete(r)
}

// The functions generates a reconcile request for each PodTracker that is affected by the update
// of the given pod
func (r *PodTrackerReconciler) findTrackersForPod(ctx context.Context, pod client.Object) []reconcile.Request {
	logger := log.FromContext(ctx).WithName("Pod Watcher")

	podTrackerList := &podsv1alpha1.PodTrackerList{}

	// List options to list PodTrackers in all namespaces
	listOps := &client.ListOptions{
		Namespace: "",
	}

	// We are only interested in PodTrackers that are tracking this specific pod.
	indexValue := fmt.Sprintf("%s/%s", pod.GetNamespace(), pod.GetName())
	trackerMatcher := &client.MatchingFields{trackerIndexKey: indexValue}

	err := r.List(ctx, podTrackerList, listOps, trackerMatcher)
	if err != nil {
		logger.Error(err, "An error occurred while listing the pod trackers for the pod", "resource", indexValue)
		return []reconcile.Request{}
	}

	logger.Info(fmt.Sprintf("Found %d matching PodTracker for pod %s", len(podTrackerList.Items), indexValue))

	reconcileRequests := make([]reconcile.Request, len(podTrackerList.Items))
	for i, item := range podTrackerList.Items {
		reconcileRequests[i] = reconcile.Request{
			NamespacedName: types.NamespacedName{
				Name:      item.GetName(),
				Namespace: item.GetNamespace(),
			},
		}
	}
	return reconcileRequests
}

var (
	// An arbitrary key that is used to filter the results of a List operation.
	trackerIndexKey = ".metadata.trackedPod"
)

type PodTrackerReconciler struct {
	client.Client
	Scheme *runtime.Scheme
}

type PodReconciler struct {
	client.Client
	Scheme *runtime.Scheme
}
