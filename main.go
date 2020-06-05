package main

import (
	"github.com/flaviostutz/ruller"
	"github.com/sirupsen/logrus"
)

func main() {
	logrus.SetLevel(logrus.DebugLevel)
	logrus.Infof("====Starting Sample JSON Rules Server====")

	//call rules registration from generated code
	rules()

	ruller.StartServer()
}
