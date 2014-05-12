from scene import *

class Frame(SceneObject):
    """
        A 3-dimensional frame scene object.
    """
    def __init__(self, sceneManager, size=[], node=None):
        if len(size) == 0:
            self.size = [1, 1, 1]
        elif len(size) == 1:
            self.size = size[0:1] + [1, 1]
        elif len(size) == 2:
            self.size = size[0:2] + [1]
        elif len(size) == 3:
            self.size = size[0:3]
        SceneObject.__init__(self, sceneManager, node)
    
    def _createMesh(self):
        mesh = self.sceneManager.createManualObject()
        sx, sy, sz = self.size[0], self.size[1], self.size[2]
        n20, n21, n22 = (sx+0.1)*0.5, (sy+0.1)*0.5, (sz+0.1)*0.5
        l0 = [-(0.5*sx+0.05), (0.5*sx+0.05)]
        l1 = [-(0.5*sy+0.05), (0.5*sy+0.05)]
        l2 = [-(0.5*sz+0.05), (0.5*sz+0.05)]
        mb = lambda : mesh.begin('red', ogre.RenderOperation.OT_LINE_STRIP)
        me = lambda : mesh.end()
        po = lambda x, y, z: mesh.position(x, y, z)
        for i in l0:
            for j in l1:
                mb()
                po(i, j, -n22)
                po(i, j, n22)
                me()
        for i in l1:
            for j in l2:
                mb()
                po(-n20, i, j)
                po(n20, i, j)
                me()
        for i in l0:
            for j in l2:
                mb()
                po(i, -n21, j)
                po(i, n21, j)
                me()
        return mesh


from random import random

class ParticlesContainer(SceneObject):
    """
        A particles container.
    """
    def __init__(self, sceneManager, size=[], count=1, scale=1.0, node=None):
        SceneObject.__init__(self, sceneManager, node)
        if len(size) != 3:
            size = [1, 1, 1]
        self.size = size
        self.mesh.setDefaultDimensions(scale, scale)
        self.n = count
        self.particles = []
        for i in range(count):
            x = (random()-0.5)*size[0]
            y = (random()-0.5)*size[1]
            z = (random()-0.5)*size[2]
            self.particles.append(self.mesh.createBillboard(Vector3(x,y,z)))
    
    def setPositions(self, r_array):
        for i in range(self.n):
            r = r_array[i]
            self.particles[i].setPosition(Vector3(r.x,r.y,r.z))
    
    def _createMesh(self):
        bs = self.sceneManager.createBillboardSet()
        bs.setMaterialName("particle")
        return bs


from time import clock

from ctypes import cdll, Structure, c_float, c_uint, byref

class V3r(Structure):
    _fields_ = [("x", c_float), ("y", c_float), ("z", c_float), ("w", c_float)] # cl_float3

host = cdll.LoadLibrary('./host.dll')


class SimulationScene(Scene):
    """
        The main scene.
    """
    
    def __init__(self, sceneManager, device, scene_setting, particles_count, work_group_size, kernel_iterations):
        self.sceneManager = sceneManager
        self.kernel_iterations = kernel_iterations
        n = (particles_count-1) / work_group_size * work_group_size + work_group_size
        sm = self.sceneManager
        self.frame = Frame(sm, [50,50,4])
        self.particlesContainer = ParticlesContainer(sm, [50,50,4], particles_count)
        c = self.particlesContainer
        V3rArray = V3r*n
        FloatArray = c_float*n
        self.m_array = FloatArray(*[0]*n)
        for i in range(particles_count):
            self.m_array[i] = c_float(2*random()+0.1)
        self.v_array = V3rArray(*[V3r(0,0,0)]*n)
        self.device = device
        if scene_setting == "rotating box":
            self._rotating_box()
        elif scene_setting == "two boxes":
            self._two_boxes()
        self.r_array = V3rArray(*[V3r(0,0,0)]*n)
        for i in range(c.n):
            self.r_array[i] = V3r(c.particles[i].getPosition().x, c.particles[i].getPosition().y, c.particles[i].getPosition().z)
        print 'initializing OpenCL...'
        host.gpu_init(c_uint(n), c_uint(work_group_size), byref(self.m_array), byref(self.r_array), byref(self.v_array))
    
    def _rotating_box(self):
        p = self.particlesContainer.particles
        v = self.v_array
        n = self.particlesContainer.n
        for i in range(n):
            v[i].x += -p[i].getPosition().y * 0.3
            v[i].y += p[i].getPosition().x * 0.3
    
    def _two_boxes(self):
        p = self.particlesContainer.particles
        v = self.v_array
        n = self.particlesContainer.n
        for i in range(n/2):
            p[i].setPosition(p[i].getPosition() + Vector3(-60,-30,0))
            v[i].x = 5
            v[i].y = -1
        for i in range(n/2,n):
            p[i].setPosition(p[i].getPosition() + Vector3(60,30,0))
            v[i].x = -5
            v[i].y = 1
    
    def reinit(self):
        pass
    
    def update(self, dt):
        if self.device == "gpu":
            self.update_gpu(dt)
        else:
            self.update_cpu(dt)
    
    def update_gpu(self, dt):
        #t0 = clock()
        for i in range(self.kernel_iterations):
            host.gpu_update()
        host.gpu_getval(byref(self.r_array))
        #t1 = clock()
        self.particlesContainer.setPositions(self.r_array)
        #t2 = clock()
        #print t1-t0, t2-t1
    
    def update_cpu(self, dt):
        n = len(self.r_array)
        #t0 = clock()
        for i in range(self.kernel_iterations):
            host.cpu_update(c_uint(n), byref(self.m_array), byref(self.r_array), byref(self.v_array))
        #t1 = clock()
        self.particlesContainer.setPositions(self.r_array)
        #t2 = clock()
        #print t1-t0, t2-t1
