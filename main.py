#!/usr/bin/python

from framework import *
from simulation import SimulationScene


class FrameListener(OgreFrameListener):

    def __init__(self, app):
        self.updating = False
        self.isEnterKeyDown = False
        self.isRKeyDown = False
        self.scene = app.scene
        self.camNode = app.camNode
        OgreFrameListener.__init__(self, app.renderWindow, app.camera)

    def _updateSimulation(self, frameEvent):
        if self.updating:
            self.scene.update(frameEvent.timeSinceLastFrame)
        return True

    def _processUnbufferedKeyInput(self, frameEvent):
        dt = frameEvent.timeSinceLastFrame
        if self.Keyboard.isKeyDown(OIS.KC_MINUS):
            self.camera.position *= 10**dt
        if self.Keyboard.isKeyDown(OIS.KC_EQUALS):
            self.camera.position /= 10**dt
        if self.Keyboard.isKeyDown(OIS.KC_R):
            if not self.isRKeyDown:
                self.updating = False
                self.scene.reinit()
                self.isRKeyDown = True
        else:
            self.isRKeyDown = False
        if self.Keyboard.isKeyDown(OIS.KC_RETURN):
            if not self.isEnterKeyDown:
                self.updating = not self.updating
                self.isEnterKeyDown = True
        else:
            self.isEnterKeyDown = False
        return not self.Keyboard.isKeyDown(OIS.KC_ESCAPE)

    def _moveCamera(self, frameEvent):
        self.camNode.yaw(self.rotationX)
        self.camNode.pitch(self.rotationY)


class Application(OgreApplication):

    def _createScene(self):
        sm = self.sceneManager
        sm.ambientLight = 1, 1, 1
        camera = sm.createCamera('Camera')
        camera.nearClipDistance = 0.1
        camNode = sm.getRootSceneNode().createChildSceneNode('CameraNode')
        camNode.attachObject(camera)
        camera.position = 0, 0, 200
        camera.lookAt(0, 0, 0)
        self.camera = camera
        self.camNode = camNode
        self.scene = SimulationScene(sm)

    def _createFrameListener(self):
        self.frameListener = FrameListener(self)
        self.root.addFrameListener(self.frameListener)
        self.frameListener.showDebugOverlay(False)


if __name__ == '__main__':
    try:
        app = Application()
        app.go()
    except ogre.OgreException, e:
        print e
