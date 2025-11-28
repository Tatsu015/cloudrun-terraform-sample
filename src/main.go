package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
	// Only respond to root path
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	// Write plain text response
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	fmt.Fprint(w, "hello")
}

func main() {
	http.HandleFunc("/", helloHandler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	addr := ":" + port
	log.Printf("starting server on %s", addr)
	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Fatalf("server failed: %v", err)
	}
}
