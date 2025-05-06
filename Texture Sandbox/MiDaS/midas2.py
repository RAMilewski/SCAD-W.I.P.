import torch
import cv2
import numpy as np
from torchvision.transforms import Compose, Resize, ToTensor, Normalize

# 1. Load MiDaS model
midas = torch.hub.load("isl-org/MiDaS", "dpt_hybrid")  # or 'dpt_beit_large_512', 'midas_v21_small', etc.
midas.eval()

# 2. Load transforms for input
midas_transforms = torch.hub.load("isl-org/MiDaS", "transforms")
transform = midas_transforms.dpt_transform  # pick depending on model

# 3. Load image and apply transform
img = cv2.imread("input.jpg")
img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
input_tensor = transform(img).unsqueeze(0)

# 4. Predict depth
with torch.no_grad():
    prediction = midas(input_tensor)

# 5. Resize to original image size
prediction = torch.nn.functional.interpolate(
    prediction.unsqueeze(1),
    size=img.shape[:2],
    mode="bicubic",
    align_corners=False,
).squeeze()

depth = prediction.cpu().numpy()

# 6. Normalize to 0–255 for viewing
depth_normalized = cv2.normalize(depth, None, 0, 255, cv2.NORM_MINMAX)
depth_normalized = depth_normalized.astype(np.uint8)

# 7. Optional: Invert or apply colormap
depth_colored = cv2.applyColorMap(255 - depth_normalized, cv2.COLORMAP_INFERNO)

# 8. Save result
cv2.imwrite("depth_gray.png", depth_normalized)
cv2.imwrite("depth_colored.png", depth_colored)
