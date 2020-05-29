package main

// the file window-size-based-on-resolution.go is used to set the initial
// dimension of the window based on screen resolution.
//
// The following example sets the window to take all of the monitor screen
// minus a border.

import (
	flutter "github.com/go-flutter-desktop/go-flutter"
	"github.com/go-gl/glfw/v3.3/glfw"
)

const windowHeight = 430
const windowWidth = 800

func init() {
	// Notice: Code in init() delays first frame!

	// Not best practice, you should let go-flutter make this call.
	err := glfw.Init()
	if err != nil {
		panic(err)
	}

	vidMoce := glfw.GetPrimaryMonitor().GetVideoMode()

	options = append(options,
		flutter.WindowInitialDimensions(
			windowWidth,
			windowHeight,
		))
	options = append(options,
		flutter.WindowInitialLocation((vidMoce.Width/2)-(windowWidth/2), (vidMoce.Height/2)-(windowHeight/2)),
	)
}
