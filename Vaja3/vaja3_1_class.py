import torch.nn as nn
import torch

# Pretvorba v sivinsko sliko
class RGBToGray(nn.Module):
    def __init__(self):
        super(RGBToGray, self).__init__()
        self.conv = nn.Conv2d(3, 1, kernel_size=1, bias=False)
        with torch.no_grad():
            self.conv.weight = nn.Parameter(torch.tensor([[[[0.299]], [[0.587]], [[0.114]]]]))

    def forward(self, x):
        return self.conv(x)
    

# Konvolucijski sloj za Sobelove filtre
class SobelFilter(nn.Module):
    def __init__(self):
        super(SobelFilter, self).__init__()
        self.conv = nn.Conv2d(1, 2, kernel_size=3, padding=1, bias=False)
        with torch.no_grad():
            self.conv.weight = nn.Parameter(torch.tensor([
                [[[1, 0, -1], [2, 0, -2], [1, 0, -1]]],  # Sx
                [[[1, 2, 1], [0, 0, 0], [-1, -2, -1]]]   # Sy
            ], dtype=torch.float32))

    def forward(self, x):
        return self.conv(x)