import torch.nn as nn
import torch


class CNN(nn.Module):
    def __init__(self, in_channels=3, num_classes=10):
        super(CNN, self).__init__()

        # convolutional layers
        self.convolutional=nn.Sequential() # initialize a new sequence of layers

        # Block 1: 2 Conv layers + MaxPool
        self.convolutional.add_module('conv1', nn.Conv2d(in_channels, out_channels=64, kernel_size=3, stride=1, padding=1))
        self.convolutional.add_module('relu1', nn.ReLU())
        self.convolutional.add_module('conv2', nn.Conv2d(in_channels=64, out_channels=64, kernel_size=3, stride=1, padding=1))
        self.convolutional.add_module('relu2', nn.ReLU())
        self.convolutional.add_module('maxpool1', nn.MaxPool2d(kernel_size=2, stride=2))

        # Block 2: 2 Conv layers + MaxPool
        self.convolutional.add_module('conv3', nn.Conv2d(in_channels=64, out_channels=128, kernel_size=3, stride=1, padding=1))
        self.convolutional.add_module('relu3', nn.ReLU())
        self.convolutional.add_module('conv4', nn.Conv2d(in_channels=128, out_channels=128, kernel_size=3, stride=1, padding=1))
        self.convolutional.add_module('relu4', nn.ReLU())
        self.convolutional.add_module('maxpool2', nn.MaxPool2d(kernel_size=2, stride=2))

        # Block 3: 3 Conv layers + MaxPool
        self.convolutional.add_module('conv5', nn.Conv2d(in_channels=128, out_channels=256, kernel_size=3, stride=1, padding=1))
        self.convolutional.add_module('relu5', nn.ReLU())
        self.convolutional.add_module('conv6', nn.Conv2d(in_channels=256, out_channels=256, kernel_size=3, stride=1, padding=1))
        self.convolutional.add_module('relu6', nn.ReLU())
        self.convolutional.add_module('conv7', nn.Conv2d(in_channels=256, out_channels=256, kernel_size=3, stride=1, padding=1))
        self.convolutional.add_module('relu7', nn.ReLU())
        self.convolutional.add_module('maxpool3', nn.MaxPool2d(kernel_size=2, stride=2))     

        # fully connected layers
        self.fully_connected = nn.Sequential() # initialize a new sequence of layers
        self.fully_connected.add_module('fc1', nn.Linear(in_features=256 * 4 * 4, out_features=512)) 
        self.fully_connected.add_module('relu_fc1', nn.ReLU())
        self.fully_connected.add_module('fc2', nn.Linear(in_features=512, out_features=512))
        self.fully_connected.add_module('relu_fc2', nn.ReLU())
        self.fully_connected.add_module('fc3', nn.Linear(in_features=512, out_features=num_classes)) 

        #self.convolutional = convolutional
        #self.fully_connected = fully_connected

    def forward(self, x):
        features=self.convolutional(x) # pass the batch through the convolutional layers
        features = torch.flatten(features, start_dim=1) # reshape the output from the convolutional part
        predictions=self.fully_connected(features) # pass the batch through the fully connected layers

        return predictions