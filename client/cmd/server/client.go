package main

import (
	"os"
	"os/exec"
	"path/filepath"
	"time"

	"go.uber.org/zap"
)

type OpenvpnClient struct {
	cmd *exec.Cmd
}

func (c *OpenvpnClient) start() {
	mutex.Lock()
	defer mutex.Unlock()

	logger.Info("Starting OpenVPN...")

	pwdFile := filepath.Join(ovpnDir, "client.pwd")
	zw := &zapWriter{}

	if _, err := os.Stat(pwdFile); os.IsNotExist(err) {
		logger.Info("client.pwd not found, starting OpenVPN without password file.", zap.Error(err))
		c.cmd = exec.Command("openvpn", "--script-security", "2", "--config", ovpnFile)
	} else {
		logger.Info("Starting OpenVPN with password file.")
		c.cmd = exec.Command("openvpn", "--script-security", "2", "--config", ovpnFile, "--askpass", pwdFile)
	}
	c.cmd.Stdout = zw
	c.cmd.Stderr = zw

	err := c.cmd.Start()
	if err != nil {
		logger.Error("Failed to start OpenVPN", zap.Error(err))
		return
	}

	go func() {
		err := c.cmd.Wait()
		if err != nil {
			logger.Debug("OpenVPN exited", zap.Error(err))
		}
	}()
}

func (c *OpenvpnClient) isActive() bool {
	mutex.Lock()
	defer mutex.Unlock()
	if c.cmd == nil || c.cmd.Process == nil {
		return false
	}
	return c.cmd.ProcessState == nil || !c.cmd.ProcessState.Exited()
}

func (c *OpenvpnClient) stop() {
	mutex.Lock()
	defer mutex.Unlock()

	if c.cmd != nil && c.cmd.Process != nil {
		logger.Info("Sending interrupt to OpenVPN...")
		if err := c.cmd.Process.Signal(os.Interrupt); err != nil {
			logger.Error("Failed to send interrupt to OpenVPN, resorting to kill", zap.Error(err))
			if err := c.cmd.Process.Kill(); err != nil {
				logger.Error("Failed to stop OpenVPN", zap.Error(err))
				return
			}
		} else {
			// Allow the process some time to clean up
			time.Sleep(5 * time.Second)
			if c.cmd.ProcessState == nil || !c.cmd.ProcessState.Exited() {
				if err := c.cmd.Process.Kill(); err != nil {
					logger.Error("Failed to kill OpenVPN after interrupt", zap.Error(err))
					return
				}
			}
		}
		c.cmd = nil
	}
}
