package main

import (
	"encoding/json"
	"net/http"
)

func healthCheckHandler(w http.ResponseWriter, r *http.Request) {
	var resp Response
	if client.isActive() {
		resp = Response{"success", "OpenVPN service is active"}
	} else {
		resp = Response{"failure", "OpenVPN service is not active"}
		w.WriteHeader(http.StatusBadRequest)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func startVpnHandler(w http.ResponseWriter, r *http.Request) {
	var resp Response
	if !client.isActive() {
		client.start()
		resp = Response{"success", "OpenVPN service started"}
	} else {
		resp = Response{"failure", "OpenVPN service is already running"}
		w.WriteHeader(http.StatusBadRequest)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func stopVpnHandler(w http.ResponseWriter, r *http.Request) {
	var resp Response
	if client.isActive() {
		client.stop()
		resp = Response{"success", "OpenVPN service stopped"}
	} else {
		resp = Response{"failure", "OpenVPN service is not running"}
		w.WriteHeader(http.StatusBadRequest)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}
