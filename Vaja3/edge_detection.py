import torch
import cv2
import numpy as np

# Read and prepare the data
path = 'hotel.jpg'  # image path
img_bgr = cv2.imread(path)  # read the image (img_bgr is a numpy array)
rgb_image = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB) # Convert BGR to RGB
img = torch.FloatTensor(rgb_image)  # convert the image into a torch tensor
img = img.permute(2, 0, 1)  / 255.0 # reshape the image from [H,W,N] to [N,H,W], where N is the number of color planes, H is the image height and W is the image width [+ normiranje]
img_batch = img.unsqueeze(0)  # prepare the batch for forward propagation

# Define convolutional kernels
grayscale_kernel = torch.FloatTensor([[[[0.299]], [[0.587]], [[0.114]]]])  # define a kernel matrix for the grayscale conversion
sobel_x = torch.FloatTensor([[[[1, 0, -1], [2, 0, -2], [1, 0, -1]]]])  # Sobel kernel for horizontal gradients
sobel_y = torch.FloatTensor([[[[1, 2, 1], [0, 0, 0], [-1, -2, -1]]]])  # Sobel kernel for vertical gradients

# Initialize the convolutional layers
conv_gray = torch.nn.Conv2d(in_channels=3, out_channels=1, kernel_size=1, bias=False)  # initialize a convolutional layer for the grayscale conversion
conv_gray.weight = torch.nn.Parameter(grayscale_kernel)  # set the weights of the first convolutional layer to the pre-defined values
conv_grad = torch.nn.Conv2d(in_channels=1, out_channels=2, kernel_size=3, bias=False, padding=1)  # initialize a convolutional layer for the calculation of x and y gradients
conv_grad.weight = torch.nn.Parameter(torch.cat([sobel_x, sobel_y], dim=0))  # set the weights of the second convolutional layer to the pre-defined values

# Process the data
img_grayscale = conv_gray(img_batch)  # propagate the batch through the first convolutional layer [prvi layer rgb in sivo out]
img_grad = conv_grad(img_grayscale)  # propagate the batch through the second convolutional layer [drugi layer sivo in gradienti out]
Gx, Gy = img_grad[:, 0, :, :], img_grad[:, 1, :, :]  # extract gradient components
G = torch.sqrt(pow(Gx, 2) + pow(Gy, 2))  # calculate gradient magnitudes

# Thresholding
threshold = 0.55  # define a threshold
G_bw = (G > threshold).float()  # binarize the grayscale image using a threshold

# Visualize results
img_grayscale = img_grayscale.squeeze(0).permute(1, 2, 0).detach().numpy()  # reformat the grayscale image into OpenCV format
img_grayscale = (img_grayscale / img_grayscale.max() * 255).astype(np.uint8)  # normalize to 0-255

G = G.squeeze(0).detach().numpy()  # normalize the image of gradient magnitudes
G = (G / G.max() * 255).astype(np.uint8)

G_bw = G_bw.squeeze(0).detach().numpy()  # normalize the binary image
img_bw = (G_bw * 255).astype(np.uint8)  # reformat the image of edges into OpenCV format

# Save images
cv2.imwrite('./slike/grayscale_image.jpg', img_grayscale)  # save the grayscale image
cv2.imwrite('./slike/gradient_image.jpg', G)  # save the gradient magnitude image
cv2.imwrite('./slike/binary_image.jpg', img_bw)  # save the binary image

# Show results
cv2.imshow('Sivinska', img_grayscale)
cv2.imshow('Gradienti', G)
cv2.imshow('Upragovljena', img_bw)
cv2.waitKey(0)
cv2.destroyAllWindows()
