#!/usr/bin/env python3
import os
import sys
import math
from PIL import Image

def run_blender_mochi():
    import bpy

    # Reset scene
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene

    # Render settings
    scene.render.engine = 'CYCLES'
    scene.cycles.device = 'CPU'
    scene.cycles.use_denoising = False
    scene.cycles.samples = 64
    scene.render.resolution_x = 256
    scene.render.resolution_y = 256
    scene.render.film_transparent = True
    scene.render.image_settings.color_mode = 'RGBA'

    # Camera setup (Orthographic, cozy isometric angle with ample framing)
    cam_data = bpy.data.cameras.new("CozyCamera")
    cam_data.type = 'ORTHO'
    cam_data.ortho_scale = 3.2
    cam_obj = bpy.data.objects.new("CozyCamera", cam_data)
    scene.collection.objects.link(cam_obj)
    scene.camera = cam_obj
    cam_obj.location = (0.0, -3.8, 1.6)
    cam_obj.rotation_euler = (math.radians(67.0), 0.0, 0.0)

    # Lighting setup (Studio 3-point warm lighting)
    # 1. Key Light (Warm golden sunlight)
    key_data = bpy.data.lights.new("KeyLight", type='AREA')
    key_data.energy = 260
    key_data.size = 2.2
    key_data.color = (1.0, 0.96, 0.90)
    key_obj = bpy.data.objects.new("KeyLight", key_data)
    scene.collection.objects.link(key_obj)
    key_obj.location = (2.2, -2.5, 3.0)
    key_obj.rotation_euler = (math.radians(45), math.radians(20), math.radians(35))

    # 2. Fill Light (Soft ambient bounce)
    fill_data = bpy.data.lights.new("FillLight", type='AREA')
    fill_data.energy = 110
    fill_data.size = 3.0
    fill_data.color = (0.88, 0.93, 1.0)
    fill_obj = bpy.data.objects.new("FillLight", fill_data)
    scene.collection.objects.link(fill_obj)
    fill_obj.location = (-2.5, -2.0, 1.6)

    # 3. Rim Light (Golden edge highlight)
    rim_data = bpy.data.lights.new("RimLight", type='AREA')
    rim_data.energy = 220
    rim_data.size = 1.6
    rim_data.color = (1.0, 0.90, 0.75)
    rim_obj = bpy.data.objects.new("RimLight", rim_data)
    scene.collection.objects.link(rim_obj)
    rim_obj.location = (0.0, 2.5, 2.8)

    # 4. Under-chin Bounce Light (Soft warm fill that eliminates neck shadow grain)
    bounce_data = bpy.data.lights.new("BounceLight", type='AREA')
    bounce_data.energy = 160
    bounce_data.size = 2.0
    bounce_data.color = (1.0, 0.95, 0.88)
    bounce_obj = bpy.data.objects.new("BounceLight", bounce_data)
    scene.collection.objects.link(bounce_obj)
    bounce_obj.location = (0.0, -1.8, 0.3)
    bounce_obj.rotation_euler = (math.radians(-30), 0.0, 0.0)

    # Materials
    def make_material(name, color, roughness=0.32):
        mat = bpy.data.materials.new(name)
        mat.use_nodes = True
        bsdf = mat.node_tree.nodes.get("Principled BSDF")
        if bsdf:
            bsdf.inputs['Base Color'].default_value = color
            bsdf.inputs['Roughness'].default_value = roughness
        return mat

    mat_body = make_material("MochiCream", (0.98, 0.95, 0.90, 1.0), roughness=0.30)
    mat_pink = make_material("EarPink", (0.97, 0.74, 0.72, 1.0), roughness=0.38)
    mat_eye = make_material("GlossEye", (0.10, 0.08, 0.08, 1.0), roughness=0.04)
    mat_eye_shine = make_material("EyeShine", (1.0, 1.0, 1.0, 1.0), roughness=0.08)
    mat_nose = make_material("CuteNose", (0.94, 0.52, 0.52, 1.0), roughness=0.25)
    mat_blush = make_material("BlushPink", (1.0, 0.68, 0.68, 1.0), roughness=0.45)
    mat_shadow = make_material("ShadowMat", (0.25, 0.18, 0.15, 0.22), roughness=0.95)

    def smooth_and_subsurf(obj, levels=2):
        for poly in obj.data.polygons:
            poly.use_smooth = True
        sub = obj.modifiers.new(name="Subsurf", type='SUBSURF')
        sub.levels = levels
        sub.render_levels = levels

    # 1. Contact Shadow
    bpy.ops.mesh.primitive_cylinder_add(radius=0.62, depth=0.005, location=(0, 0, 0.005))
    shadow_obj = bpy.context.active_object
    shadow_obj.name = "ContactShadow"
    shadow_obj.scale = (1.05, 0.72, 1.0)
    shadow_obj.data.materials.append(mat_shadow)

    # 2. Body (Squishy chubby base)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=28, ring_count=18, radius=0.52, location=(0, 0.02, 0.44))
    body = bpy.context.active_object
    body.name = "Body"
    body.scale = (1.02, 0.92, 0.82)
    body.data.materials.append(mat_body)
    smooth_and_subsurf(body, 2)

    # 3. Head (Large cute chibi sphere)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=22, radius=0.62, location=(0, -0.04, 1.02))
    head = bpy.context.active_object
    head.name = "Head"
    head.scale = (1.14, 0.98, 0.94)
    head.data.materials.append(mat_body)
    smooth_and_subsurf(head, 2)

    # 4. Cat Ears (Upright, perky, cute)
    for side, x_mult in [("L", -1.0), ("R", 1.0)]:
        bpy.ops.mesh.primitive_cone_add(radius1=0.22, depth=0.36, location=(x_mult * 0.38, -0.05, 1.56))
        ear = bpy.context.active_object
        ear.name = f"EarOuter_{side}"
        ear.rotation_euler = (math.radians(-6), math.radians(x_mult * -18), math.radians(x_mult * 10))
        ear.scale = (0.85, 0.40, 1.15)
        ear.data.materials.append(mat_body)
        smooth_and_subsurf(ear, 1)

        bpy.ops.mesh.primitive_cone_add(radius1=0.15, depth=0.26, location=(x_mult * 0.38, -0.12, 1.55))
        ear_in = bpy.context.active_object
        ear_in.name = f"EarInner_{side}"
        ear_in.rotation_euler = (math.radians(-6), math.radians(x_mult * -18), math.radians(x_mult * 10))
        ear_in.scale = (0.72, 0.28, 0.95)
        ear_in.data.materials.append(mat_pink)
        smooth_and_subsurf(ear_in, 1)

    # 5. Kawaii Eyes (Bigger, more expressive)
    for side, x_mult in [("L", -1.0), ("R", 1.0)]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.082, location=(x_mult * 0.25, -0.58, 1.02))
        eye = bpy.context.active_object
        eye.name = f"Eye_{side}"
        eye.scale = (0.95, 0.55, 1.15)
        eye.data.materials.append(mat_eye)
        smooth_and_subsurf(eye, 1)

        # Primary catchlight
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.030, location=(x_mult * 0.22 + (x_mult * -0.016), -0.63, 1.07))
        shine1 = bpy.context.active_object
        shine1.name = f"EyeShine1_{side}"
        shine1.data.materials.append(mat_eye_shine)

        # Secondary micro-catchlight
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.015, location=(x_mult * 0.28 + (x_mult * -0.016), -0.62, 0.98))
        shine2 = bpy.context.active_object
        shine2.name = f"EyeShine2_{side}"
        shine2.data.materials.append(mat_eye_shine)

        # Rosy Cheeks
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.090, location=(x_mult * 0.42, -0.50, 0.89))
        blush = bpy.context.active_object
        blush.name = f"Blush_{side}"
        blush.scale = (1.05, 0.32, 0.65)
        blush.data.materials.append(mat_blush)
        smooth_and_subsurf(blush, 1)

    # 6. Button Nose
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.032, location=(0.0, -0.63, 0.96))
    nose = bpy.context.active_object
    nose.name = "Nose"
    nose.scale = (1.25, 0.55, 0.85)
    nose.data.materials.append(mat_nose)
    smooth_and_subsurf(nose, 1)

    # 7. Front Paws
    for side, x_mult in [("L", -1.0), ("R", 1.0)]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.14, location=(x_mult * 0.25, -0.36, 0.12))
        paw = bpy.context.active_object
        paw.name = f"Paw_{side}"
        paw.scale = (0.95, 1.3, 0.65)
        paw.data.materials.append(mat_body)
        smooth_and_subsurf(paw, 1)

    # 8. Chubby Curled Tail
    bpy.ops.mesh.primitive_cylinder_add(radius=0.08, depth=0.44, location=(0.38, 0.28, 0.30))
    tail = bpy.context.active_object
    tail.name = "Tail"
    tail.rotation_euler = (math.radians(-25), math.radians(45), math.radians(55))
    tail.data.materials.append(mat_body)
    smooth_and_subsurf(tail, 1)

    # Save canonical 3D source files (.blend and .glb)
    export_dir = "/home/runner/first-vibecode-game/assets/3d"
    os.makedirs(export_dir, exist_ok=True)
    blend_path = os.path.join(export_dir, "mochi_cat.blend")
    glb_path = os.path.join(export_dir, "mochi_cat.glb")
    bpy.ops.wm.save_as_mainfile(filepath=blend_path)
    bpy.ops.export_scene.gltf(filepath=glb_path, export_format='GLB')
    print(f"Saved 3D Blend: {blend_path}")
    print(f"Exported 3D GLB: {glb_path}")

    # Render animation frames
    out_dir = "/tmp/mochi_cat_raw"
    os.makedirs(out_dir, exist_ok=True)

    poses = {
        "idle_0": {"head_z": 0.96, "body_s": (0.95, 0.88, 0.85), "eye_open": True},
        "idle_1": {"head_z": 0.94, "body_s": (0.98, 0.91, 0.82), "eye_open": True}, # Breathing squash
        "idle_2": {"head_z": 0.97, "body_s": (0.94, 0.86, 0.87), "eye_open": True}, # Stretch
        "joy":    {"head_z": 1.05, "body_s": (0.88, 0.80, 0.95), "eye_open": False}, # Bounce up
        "sleep":  {"head_z": 0.86, "body_s": (1.05, 0.98, 0.68), "eye_open": False}, # Cozy curled
        "eat":    {"head_z": 0.93, "body_s": (1.02, 0.92, 0.83), "eye_open": True},  # Chubby cheeks
    }

    for name, config in poses.items():
        head.location.z = config["head_z"]
        body.scale = config["body_s"]
        
        # Toggle eye state if closed
        for side in ["L", "R"]:
            eye_obj = bpy.data.objects.get(f"Eye_{side}")
            shine_obj = bpy.data.objects.get(f"EyeShine_{side}")
            if eye_obj and shine_obj:
                if not config["eye_open"]:
                    eye_obj.scale = (1.2, 0.2, 0.15) # Happy closed curved slit
                    shine_obj.hide_render = True
                else:
                    eye_obj.scale = (0.9, 0.5, 1.1)
                    shine_obj.hide_render = False

        render_path = os.path.join(out_dir, f"{name}.png")
        scene.render.filepath = render_path
        bpy.ops.render.render(write_still=True)
        print(f"Rendered pose: {name} -> {render_path}")

    return out_dir

def process_and_trim_sprites(raw_dir):
    """Calculates unified alpha bounds across all rendered frames and crops to zero-padding with smoothing."""
    from PIL import ImageFilter
    out_sprites_dir = "/home/runner/first-vibecode-game/assets/sprites/critters/mochi_cat"
    os.makedirs(out_sprites_dir, exist_ok=True)

    images = {}
    min_x, min_y, max_x, max_y = 9999, 9999, -1, -1

    for fname in os.listdir(raw_dir):
        if not fname.endswith(".png"):
            continue
        p = os.path.join(raw_dir, fname)
        img = Image.open(p).convert("RGBA")
        bbox = img.getbbox() # (left, upper, right, lower)
        if bbox:
            min_x = min(min_x, bbox[0])
            min_y = min(min_y, bbox[1])
            max_x = max(max_x, bbox[2])
            max_y = max(max_y, bbox[3])
            images[fname] = img

    print(f"Global Unified Bounding Box across all frames: ({min_x}, {min_y}, {max_x}, {max_y})")
    target_w = max_x - min_x
    target_h = max_y - min_y
    print(f"Zero-padded Sprite Dimensions: {target_w}x{target_h}px")

    # Crop every image to the exact unified bounding box and apply gentle bilateral smoothing
    processed_images = {}
    for fname, img in images.items():
        cropped = img.crop((min_x, min_y, max_x, max_y))
        r, g, b, a = cropped.split()
        rgb = Image.merge('RGB', (r, g, b))
        rgb_smooth = rgb.filter(ImageFilter.SMOOTH)
        final_img = Image.merge('RGBA', (*rgb_smooth.split(), a))
        
        out_path = os.path.join(out_sprites_dir, fname)
        final_img.save(out_path)
        processed_images[fname] = final_img
        print(f"Saved optimized zero-padded sprite: {out_path} ({final_img.size[0]}x{final_img.size[1]})")

    # Build a horizontal sprite sheet
    sheet_w = target_w * len(processed_images)
    sheet_h = target_h
    spritesheet = Image.new("RGBA", (sheet_w, sheet_h), (0, 0, 0, 0))
    idx = 0
    for fname in sorted(processed_images.keys()):
        spritesheet.paste(processed_images[fname], (idx * target_w, 0))
        idx += 1
    
    sheet_path = "/home/runner/first-vibecode-game/assets/sprites/critters/mochi_cat_sheet.png"
    spritesheet.save(sheet_path)
    print(f"Generated unified sprite sheet: {sheet_path} ({sheet_w}x{sheet_h})")

if __name__ == "__main__":
    raw_dir = run_blender_mochi()
    process_and_trim_sprites(raw_dir)
