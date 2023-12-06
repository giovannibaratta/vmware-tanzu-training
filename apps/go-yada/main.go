package main

import (
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
)

type TemplateData struct {
	Secrets map[string]string
}

var dirToMonitor string

func healthzHandler(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("All good 👍"))
}

func listSecretsHandler(w http.ResponseWriter, r *http.Request) {

	entries, listDirErr := os.ReadDir(dirToMonitor)

	if listDirErr != nil {
		returnErrorPage(listDirErr, w)
		return
	}

	templateData := TemplateData{
		Secrets: map[string]string{},
	}

	for _, entry := range entries {

		if entry.IsDir() {
			continue
		}

		secretValue, err := readSecretFromFile(fmt.Sprintf("%v/%v", dirToMonitor, entry.Name()))

		if err != nil {
			returnErrorPage(err, w)
			return
		}

		templateData.Secrets[entry.Name()] = secretValue
	}

	fmt.Printf("Data: %+v\n", templateData)

	t, err := template.ParseFiles("html/secret.html")

	if err != nil {
		returnErrorPage(err, w)
		return
	}

	// Inject the data into the template and write the result to the http response
	t.Execute(w, templateData)
}

func returnErrorPage(err error, w http.ResponseWriter) {
	w.WriteHeader(http.StatusInternalServerError)
	w.Write([]byte("Unable to find/read secret from directory.\nError: "))
	w.Write([]byte(err.Error()))
}

func readSecretFromFile(path string) (string, error) {
	content, err := os.ReadFile(path)
	if err != nil {
		return "", err
	}
	return string(content), nil
}

func main() {

	dirToMonitor = os.Getenv("DIR_TO_MONITOR")

	if dirToMonitor == "" {
		fmt.Println("DIR_TO_MONITOR not set or empty")
		os.Exit(1)
	}

	http.HandleFunc("/secrets", listSecretsHandler)
	http.HandleFunc("/healthz", healthzHandler)
	log.Fatal(http.ListenAndServe(":8080", nil))
}
