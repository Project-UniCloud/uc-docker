package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"strings"
)

var (
	secret  string
	repoDir string
)

func init() {
	secret = os.Getenv("WEBHOOK_SECRET")
	if secret == "" {
		log.Fatal("WEBHOOK_SECRET is not set")
	}
	repoDir = os.Getenv("REPO_DIR")
	if repoDir == "" {
		log.Fatal("REPO_DIR is not set")
	}
}

var allowedServices = map[string]bool{
	"backend":     true,
	"frontend":    true,
	"adapter-aws": true,
}

func runCommand(cmd *exec.Cmd) error {
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("%v: %s", err, string(output))
	}
	log.Printf("Command output: %s", output)
	return nil
}

func restartHandler(w http.ResponseWriter, r *http.Request) {
	auth := r.Header.Get("Authorization")
	if auth != "Bearer "+secret {
		http.Error(w, "Forbidden", http.StatusForbidden)
		return
	}

	parts := strings.Split(r.URL.Path, "/")
	if len(parts) != 3 {
		http.Error(w, "Invalid URL format", http.StatusBadRequest)
		return
	}

	service := parts[2]
	if !allowedServices[service] {
		http.Error(w, "Service not allowed", http.StatusBadRequest)
		return
	}

	log.Printf("Restarting service: %s", service)

	// Git pull
	cmdGit := exec.Command("git", "-C", repoDir, "pull")
	if err := runCommand(cmdGit); err != nil {
		http.Error(w, "Git pull failed: "+err.Error(), http.StatusInternalServerError)
		return
	}

	envFile := repoDir + "/.env"
	composeFile := repoDir + "/docker-compose.yml"
	devComposeFile := repoDir + "/docker-compose.dev.yml"

	baseArgs := []string{
		"--preserve-env", "docker", "compose",
		"--env-file", envFile,
		"-f", composeFile,
		"-f", devComposeFile,
	}

	// docker compose down [service]
	cmdDown := exec.Command("sudo", append(baseArgs, "down", service)...)
	if err := runCommand(cmdDown); err != nil {
		http.Error(w, "Docker down failed: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// docker compose up -d [service]
	cmdUp := exec.Command("sudo", append(baseArgs, "up", "-d", service)...)
	if err := runCommand(cmdUp); err != nil {
		http.Error(w, "Docker up failed: "+err.Error(), http.StatusInternalServerError)
		return
	}

	msg := fmt.Sprintf("Service %s restarted successfully", service)
	w.Write([]byte(msg))
}

func main() {
	http.HandleFunc("/restart-webhook/", restartHandler)
	log.Println("Webhook server listening on :3001")
	log.Fatal(http.ListenAndServe(":3001", nil))
}
