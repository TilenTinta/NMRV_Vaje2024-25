import argparse
import dataloader
from network import CNN
import torch
from tqdm import tqdm
import os
from torch.optim.lr_scheduler import StepLR
from torch.optim.lr_scheduler import ReduceLROnPlateau
import matplotlib.pyplot as plt
import numpy as np

# Class label names
cifar10_classes = [
    'airplane', 'automobile', 'bird', 'cat', 'deer',
    'dog', 'frog', 'horse', 'ship', 'truck'
]

mnist_classes = [str(i) for i in range(10)]  # ['0', '1', '2', ..., '9']

# added paths
root_path = 'C:/DATA/Faks/Elektrotehnika_MAG/2_Letnik/Napredne_metode_racunalniskega_vida/Vaje/NMRV_Vaje2024-25/Vaja3/classifier/'

dataset = 'MNIST_ST'
#dataset = 'cifar-10-batches-py'

show_misspredict = 0
acc_list = []
loss_list = []

if dataset == "MNIST_ST":
    dataset_path = os.path.join(root_path + dataset)
    output_path = os.path.join(root_path + "output/CNN_weights_MNIST.pth")
    class_names = mnist_classes
elif dataset == "cifar-10-batches-py":
    dataset_path = os.path.join(root_path + dataset)
    output_path = os.path.join(root_path + "output/CNN_weights_CIFAR10.pth")
    class_names = cifar10_classes
else:
    print("Neki ne štima...")


# arguments that can be defined upon execution of the script
options = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
options.add_argument('--dataset', default=dataset, help='folder | cifar10 | mnist ')
options.add_argument('--dataroot', default=dataset_path, help='root directory of the dataset') 
options.add_argument('--batchsize', type=int, default=512, help='input batch size')
options.add_argument('--imagesize', type=int, default=32, help='size of the image (height, width)')
options.add_argument('--epochs', type=int, default=20, help='number of training epochs')
opt = options.parse_args()

# Define dataloaders
train_data, test_data = dataloader.load_data(path=opt.dataroot, dataset=opt.dataset, imagesize=opt.imagesize, batchsize=opt.batchsize)

# Load the CNN model
device = "cuda:0"
model = CNN().to(device)

# Initilaize empty tensors for image batches and ground truth labels
images = torch.empty(size=(opt.batchsize, 3, opt.imagesize, opt.imagesize), dtype=torch.float32, device=device)
gt = torch.empty(size=(opt.batchsize,), dtype=torch.long, device=device)

# Initialize the loss function
l_ce = torch.nn.CrossEntropyLoss()

# Initialize the optimizer
optimizer = torch.optim.Adam(model.parameters(), lr=0.0001, betas=(0.9, 0.999))

# Initialize the scheduler
#scheduler = StepLR(optimizer, step_size=2, gamma=0.00002)  # Reduce LR every 2 epochs
#scheduler = ReduceLROnPlateau(optimizer, mode='min', factor=0.00002, patience=5)

best_acc=0

# List to store misclassified images and labels
misclassified_images = []
misclassified_labels = []
misclassified_predictions = []

for epoch in range(opt.epochs):
    print("Training epoch: {}".format(epoch+1))
    # Set the CNN to train mode
    model.train()

    avg_loss = 0
    # Iterate through all batches
    for i_batch, input in tqdm(enumerate(train_data), total=len(train_data)):
        images.copy_(input[0]) # copy the batch in images
        gt.copy_(input[1]) # copy ground truth labels in gt

        optimizer.zero_grad() # Set all gradients to 0
        predictions = model(images) # Feedforward
        loss=l_ce(predictions, gt) # Calculate the error of the current batch
        avg_loss+=loss
        loss.backward() # Calculate gradients with backpropagation
        optimizer.step() # optimize weights for the next batch
    print("Epoch {}: average loss: {}". format(epoch+1, avg_loss/len(train_data)))
    avg_loss = avg_loss / len(train_data)  # Calculate average loss for the epoch
    loss_list.append(avg_loss.detach().cpu().item())  # Append the float value to the loss list


    print("Testing the model...")
    # Set the CNN to test mode
    model.eval()

    total_correct = 0
    total_samples = 0
    #total_val_loss = 0  # To accumulate validation loss

    with torch.no_grad():
        for i_batch, input in tqdm(enumerate(test_data), total=len(test_data)):
            test_images=input[0].to(device)
            test_labels=input[1].to(device)

            #predictions = model(test_images)
            #loss = l_ce(predictions, test_labels)  # Compute validation loss
            #total_val_loss += loss.item()  # Accumulate loss

            _, predicted_labels = torch.max(model(test_images), dim=1)

            # Check what is the number of correctly classified samples
            total_correct += (predicted_labels == test_labels).sum().item()
            total_samples += test_labels.size(0)

            # Save misclassified samples
            for i in range(len(test_labels)):
                if predicted_labels[i] != test_labels[i]:  # Misclassification
                    misclassified_images.append(test_images[i].cpu().numpy())  # Save the image
                    misclassified_labels.append(class_names[test_labels[i].item()])  # True label
                    misclassified_predictions.append(class_names[predicted_labels[i].item()])  # Predicted label
        
    # Calculate accuracy
    acc = total_correct / total_samples
    acc_list.append(acc)
    #avg_val_loss = total_val_loss / len(test_data)  # Average validation loss

    # save network weights when the accuracy is great than the best_acc
    if acc>best_acc:
        torch.save({'epoch': epoch, 'state_dict': model.state_dict()}, output_path)
        best_acc = acc

    print("Average accuracy: {}     Best accuracy: {}".format(acc, best_acc))

    # Display the first 10 misclassified images
    if show_misspredict == 1:
        print("Displaying 10 misclassified images:")
        fig, axes = plt.subplots(2, 5, figsize=(20, 8))  # 2 rows, 5 columns

        for i in range(min(10, len(misclassified_images))):  # Show up to 10
            img = misclassified_images[i]
            img = np.transpose(img, (1, 2, 0))  # Convert CHW to HWC for plotting
            img = (img - img.min()) / (img.max() - img.min())  # Normalize to [0, 1]

            ax = axes[i // 5, i % 5]  # Access axes in a 2x5 grid
            ax.imshow(img)
            ax.set_title(f"True: {misclassified_labels[i]}\nPred: {misclassified_predictions[i]}")
            ax.axis('off')  # Turn off axis ticks

        plt.tight_layout()  # Adjust spacing between subplots
        plt.show(block=True)  # Don't prevent program from proceeding until plot window is closed

    # Step the scheduler
    #scheduler.step(avg_val_loss)
    #print(f"Learning rate for next epoch: {scheduler.get_last_lr()}")

# Plot Accuracy
plt.subplot(1, 2, 1)
plt.plot(range(1, len(acc_list) + 1), acc_list, marker='o', linestyle='-', label='Accuracy')
plt.xlabel('Epoch')
plt.ylabel('Accuracy')
plt.title('Model Accuracy Over Epochs')
plt.grid(True)
plt.legend()

# Plot Loss
plt.subplot(1, 2, 2)
plt.plot(range(1, len(loss_list) + 1), loss_list, marker='o', linestyle='-', color='r', label='Loss')
plt.xlabel('Epoch')
plt.ylabel('Loss')
plt.title('Model Loss Over Epochs')
plt.grid(True)
plt.legend()

plt.tight_layout()
plt.show()


########## REZULTATI ##########
# CIFAR-10 - Best accuracy: 0.7923
# NMIST - Best accuracy: 0.9942873464724364

