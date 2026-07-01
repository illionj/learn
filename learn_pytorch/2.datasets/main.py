import sys
from pathlib import Path


import torch
from torch.utils.data import Dataset
from torchvision import datasets
from torchvision.transforms import ToTensor
# %%
import matplotlib.pyplot as plt
from torchvision.io import decode_image
import pandas as pd
import os




PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))


from common import get_logger
log = get_logger("tensor", console_style="simple", enable_file=False)
DATA_ROOT = PROJECT_ROOT.joinpath("data")

from torch.utils.data import DataLoader


class CustomImageDataset(Dataset):
    def __init__(self,annotations_file,img_dir,transform=None,target_transform=None):
        self.img_labels=pd.read_csv(annotations_file)
        self.img_dir=img_dir
        self.transform=transform
        self.target_transform=target_transform

    def __len__(self):
        return len(self.img_dir)
    
    def __getitem__(self, idx):
        img_path = os.path.join(self.img_dir, self.img_labels.iloc[idx, 0])
        image = decode_image(img_path)
        label = self.img_labels.iloc[idx, 1]
        if self.transform:
            image = self.transform(image)
        if self.target_transform:
            label = self.target_transform(label)
        return image, label                  




if __name__ == "__main__":
    training_data=datasets.FashionMNIST(
        root=DATA_ROOT,
        train=True,
        download=False,
        transform=ToTensor()
    )

    test_data=datasets.FashionMNIST(
        root=DATA_ROOT,
        train=False,
        download=False,
        transform=ToTensor()
    )


    labels_map={
        0:"T-Shirt",
        1:"Trouser",
        2:"Pullover",
        3:"Dress",
        4:"Coat",
        5:"Sandal",
        6:"Shirt",
        7:"Sneaker",
        8:"Bag",
        9:"Ankle Boot"
    }

    figure=plt.figure(figsize=(8,8))

    cols,rows=3,3

    for i in range(1,cols*rows+1):
        sample_idx=torch.randint(len(training_data),size=(1,)).item()
        img,label=training_data[sample_idx]
        figure.add_subplot(rows,cols,i)
        plt.title(labels_map[label])
        plt.axis("off")
        plt.imshow(img.squeeze(),cmap="gray")
    plt.show()


    # shuffle会在每次从可迭代对象中创建迭代器时生效,即iter(training_dataloader)
    # python的正常for循环会默认加上iter,因此每次创建迭代器的时候都会将整个数据索引打乱,然后按照64分组
    # 注意这里的shuffle,对于小数据集 每个迭代器维护一个乱序索引数组
    # 对于多进程加载,则是由一个主进程控制其他work的取索引内容
    # 对于超大数据,都是近似采样和流式取出(不是让pytorch做,而是需要定制)
    # 注意 随机采样是O(N) 但它不是迭代器的开销
    training_dataloader=DataLoader(training_data,batch_size=64,shuffle=True)
    test_dataloader=DataLoader(test_data,batch_size=64,shuffle=True)

    training_features,training_label=next(iter(training_dataloader))
    log.info(f"Feature batch shape:{training_features.size()}")
    log.info(f"Labels batch shape:{training_label.size()}")
    img=training_features[0].squeeze()
    label=training_label[0]
    plt.imshow(img,cmap='gray')
    plt.show()
    log.info(f"Label:{label}")


