import bpy, os

def loadTile( displacementMapPath ):
    realPath = displacementMapPath
    bpy.ops.mesh.primitive_plane_add(radius=1)

    obj = bpy.context.selected_objects[0]
    
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.subdivide()
    bpy.ops.mesh.subdivide()
    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.object.shade_smooth()

    bpy.ops.object.modifier_add(type='SUBSURF')
    subd = obj.modifiers['Subsurf']
    subd.subdivision_type = 'SIMPLE'
    subd.levels = 5

    bpy.ops.object.modifier_add(type='DISPLACE')
    disp = obj.modifiers['Displace']
    
    img = bpy.data.images.load(realPath)
    dTex = bpy.data.textures.new('DisplacementTex', type='IMAGE')
    dTex.image = img
    
    disp.texture = dTex
    
    obj.scale = [128.0, 128.0, 36]
    #bpy.ops.object.transform_apply(location=False, scale=True, rotation=False)
    
loadTile(os.path.expanduser('~\\Desktop\\testmap.tif'))
    
    

