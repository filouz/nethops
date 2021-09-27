package main

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

var (
	logger  *zap.Logger
	mutex   = &sync.Mutex{}
	client  OpenvpnClient
	ovpnDir = os.Getenv("OVPN_DIR")

	ovpnFile string
)

type Response struct {
	Status  string `json:"status"`
	Message string `json:"message"`
}

func init() {
	encoderCfg := zapcore.EncoderConfig{
		TimeKey:        "timestamp",
		LevelKey:       "level",
		NameKey:        "logger",
		CallerKey:      "caller",
		MessageKey:     "message",
		StacktraceKey:  "stacktrace",
		LineEnding:     zapcore.DefaultLineEnding,
		EncodeLevel:    zapcore.LowercaseLevelEncoder,
		EncodeTime:     TimeEncoder,
		EncodeDuration: zapcore.SecondsDurationEncoder,
		EncodeCaller:   zapcore.ShortCallerEncoder,
	}
	core := zapcore.NewCore(zapcore.NewConsoleEncoder(encoderCfg), os.Stdout, zapcore.DebugLevel)
	logger = zap.New(core, zap.AddCaller())

	ovpnFile = filepath.Join(ovpnDir, "client.ovpn")
	if _, err := os.Stat(ovpnFile); os.IsNotExist(err) {
		logger.Fatal("client.ovpn not found", zap.Error(err))
	}
}

func TimeEncoder(t time.Time, enc zapcore.PrimitiveArrayEncoder) {
	enc.AppendString(t.Format(time.RFC3339))
}

type zapWriter struct {
}

func (zw zapWriter) Write(p []byte) (n int, err error) {
	fmt.Println(strings.TrimSpace(string(p)))
	return len(p), nil
}

func main() {
	defer logger.Sync()

	go client.start()

	http.HandleFunc("/healthz", healthCheckHandler)
	http.HandleFunc("/start", startVpnHandler)
	http.HandleFunc("/stop", stopVpnHandler)
	logger.Info("Starting HTTP server...")
	http.ListenAndServe(":8080", nil)
}
