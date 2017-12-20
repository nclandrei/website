package main

import (
	"fmt"
	"net/http"
)

// IndexTemplate defines variables used on the index page
type IndexTemplate struct {
	Title string
}

// Basic handler
func viewHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "<h1>HELLO WORLD!</h1>")
}

func blogHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "templates/index.html")
}

func main() {
	http.HandleFunc("/", viewHandler)
	http.HandleFunc("/blog", blogHandler)
	http.ListenAndServe(":8080", nil)
}
