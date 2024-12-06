from torchvision import transforms, datasets
from torch.utils.data import DataLoader, Dataset
import os
import cv2

def load_data(path, dataset, imagesize, batchsize):
    print(f"Loading dataset {dataset}.")

    # Define data transformations (resize, normalize, convert to tensors)
    transform = transforms.Compose([
        transforms.Resize(imagesize),
        transforms.ToTensor(),
        transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))  # Standard mean and std for CIFAR-10
    ])

    if dataset == 'MNIST_ST': # .lower()
        # Custom dataset logic for MNIST_ST
        train_samples, test_samples = make_dataset(os.path.join(path, dataset))
        train_ds = DataFolder(train_samples, transform=transform)
        train_dl = DataLoader(dataset=train_ds, batch_size=batchsize, shuffle=True, drop_last=True)
        test_ds = DataFolder(test_samples, transform=transform)
        test_dl = DataLoader(dataset=test_ds, batch_size=batchsize, shuffle=False, drop_last=False)

    elif dataset.lower() == 'cifar-10-batches-py':
        # Use torchvision's CIFAR-10 loader
        train_ds = datasets.CIFAR10(root=path, train=True, download=True, transform=transform)
        test_ds = datasets.CIFAR10(root=path, train=False, download=True, transform=transform)
        train_dl = DataLoader(dataset=train_ds, batch_size=batchsize, shuffle=True, drop_last=True)
        test_dl = DataLoader(dataset=test_ds, batch_size=batchsize, shuffle=False, drop_last=False)
    else:
        raise ValueError(f"Unsupported dataset: {dataset}")

    return train_dl, test_dl



from PIL import Image

class DataFolder(Dataset):
    def __init__(self, samples, transform=None):
        self.samples = samples
        self.transform = transform

    def __getitem__(self, item_index):
        path, target = self.samples[item_index]
        img = cv2.imread(path)

        # Debug: Check if the image was loaded
        if img is None:
            raise FileNotFoundError(f"Image not found or cannot be read: {path}")

        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)  # Convert BGR (OpenCV) to RGB
        img = Image.fromarray(img)  # Convert NumPy array to PIL Image

        if self.transform:
            img = self.transform(img)

        return img, target

    def __len__(self):
        return len(self.samples)

def make_dataset(dir):
    train_samples = []
    test_samples = []

    # Directories for train and test
    train_dir = os.path.join(dir, "train")
    test_dir = os.path.join(dir, "test")

    # Class directories for train and test
    for split_dir, sample_list in [(train_dir, train_samples), (test_dir, test_samples)]:
        if not os.path.isdir(split_dir):
            print(f"WARNING: {split_dir} is not a directory. Skipping.")
            continue

        class_names = sorted(os.listdir(split_dir))  # e.g., ['0', '1', ..., '9']
        class_to_id = {key: i for i, key in enumerate(class_names)}

        for class_name in class_names:
            class_path = os.path.join(split_dir, class_name)
            if not os.path.isdir(class_path):
                print(f"WARNING: {class_path} is not a directory. Skipping.")
                continue

            # Collect all image files in this class directory
            image_files = sorted(os.listdir(class_path))
            for image_file in image_files:
                image_path = os.path.join(class_path, image_file)
                if not os.path.isfile(image_path):
                    print(f"WARNING: {image_path} is not a valid file. Skipping.")
                    continue

                # Add to the appropriate sample list (train or test)
                sample_list.append((os.path.normpath(image_path), class_to_id[class_name]))

    print(f"Total training samples: {len(train_samples)}")
    print(f"Total testing samples: {len(test_samples)}")

    return train_samples, test_samples


def calculate_mean_std(path, dataset, imagesize):

    return (0.5, 0.5, 0.5), (0.5, 0.5, 0.5) # return mean and std values