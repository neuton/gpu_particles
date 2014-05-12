import OGRE as ogre
from OGRE import Vector3
#import ogre.renderer.OGRE as ogre
#from ogre.renderer.OGRE import Vector3


class Scene():
    """ The main scene. """
    
    def __init__(self, sceneManager):
        self.sceneManager = sceneManager
    
    def reinit(self):
        pass
    
    def update(self, dt):
        pass


class SceneObject:
    """
        Base scene object class for inheritance.
    """
    def __init__(self, sceneManager, node=None, mesh=None):
        if sceneManager is None:
            raise Exception('sceneManager is None!')
        #if node is not None and not sceneManager.hasSceneNode(node.name): #don't know how to handle this
        #    raise Exception('node is not in sceneManager!')
        self.sceneManager = sceneManager
        if node is None:
            self.node = self._createNode()
        else:
            self.node = node
        if mesh is None:
            self.mesh = self._createMesh()
        else:
            self.mesh = mesh
        if self.mesh is not None:
            self.node.attachObject(self.mesh)

    def _createNode(self):
        return self.sceneManager.getRootSceneNode()

    def _createMesh(self):
        return None

    def remove(self):
        if isinstance(self.mesh, ogre.Entity):
            self.sceneManager.destroyEntity(self.mesh)
        elif isinstance(self.mesh, ogre.ManualObject):
            self.sceneManager.destroyManualObject(self.mesh)
        if self.node is not None and not (self.node.name == 'Ogre/SceneRoot'):
            self.sceneManager.destroySceneNode(self.node)
