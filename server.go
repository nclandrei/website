package main

import (
	"fmt"
	"net/http"
)

// Basic handler
func viewHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "<h1>HELLO WORLD!</h1>")
}

func main() {
	http.HandleFunc("/", viewHandler)
	http.ListenAndServe(":8080", nil)
}
