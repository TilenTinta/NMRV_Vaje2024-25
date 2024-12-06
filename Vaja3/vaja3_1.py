import cv2
import torch
import numpy as np
import vaja3_1_class as v3class
   
    
######################################################
######################## MAIN ########################
######################################################

if __name__ == "__main__":

    image = cv2.imread("hotel.jpg") # import slike

    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB) # Predelava zapisa če ni RGB

    # Pretvori sliko v tenzor in normaliziraj
    image_tensor = torch.tensor(image, dtype=torch.float32).permute(2, 0, 1).unsqueeze(0) / 255.0

    # Pretvori v sivinsko
    rgb_to_gray = v3class.RGBToGray()
    gray_image = rgb_to_gray(image_tensor)

    # Ustvari model za Sobel
    sobel_filter = v3class.SobelFilter()
    gradient = sobel_filter(gray_image)

    # Izračunaj magnitude gradientov
    Gx, Gy = gradient[:, 0, :, :], gradient[:, 1, :, :]
    magnitude = torch.sqrt(pow(Gx, 2) + pow(Gy, 2))

    # Normalizacija slike
    magnitude = magnitude.squeeze(0).detach()
    magnitude = (magnitude - magnitude.min()) / (magnitude.max() - magnitude.min())
    magnitude_np = magnitude.numpy()

    # Upragovljanje
    threshold = 0.15  # test
    binary_edges = (magnitude > threshold).float()

    # Convert v OpenCV
    gray_image_np = gray_image.squeeze(0).squeeze(0).detach().numpy()
    gray_image_np = (gray_image_np * 255).astype(np.uint8)

    binary_edges = binary_edges.squeeze(0).squeeze(0).numpy()
    binary_edges = (binary_edges * 255).astype(np.uint8)

    cv2.imwrite("./slike/original.jpg", cv2.cvtColor(image, cv2.COLOR_RGB2BGR))
    cv2.imwrite("./slike/siva.jpg", gray_image_np)
    cv2.imwrite("./slike/sobel.jpg", binary_edges)

    cv2.imshow("Original", cv2.cvtColor(image, cv2.COLOR_RGB2BGR))
    cv2.imshow("Sivinska", gray_image_np)
    cv2.imshow("Sobel", binary_edges)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
