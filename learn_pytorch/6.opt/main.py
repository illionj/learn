import sys
from pathlib import Path


# __file__
# 表示当前这个 Python 文件自己的路径。

# Path(__file__)
# 把这个路径字符串包装成 Path 对象，方便继续做路径操作。

# .resolve()
# 把路径转成绝对路径，并尽量消除相对路径或软链接影响。

# .parent
# 表示“当前文件所在目录”。
# parents[2] 的意思是：
# 从当前文件路径开始，向上找第 3 层父目录。
PROJECT_ROOT=Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0,str(PROJECT_ROOT))


from common import get_logger
log=get_logger(__name__,console_style="simple",enable_file=False)
DATA_ROOT=PROJECT_ROOT.joinpath("data")

import os
import torch 
from torch import nn
from torch.utils.data import DataLoader
from torchvision import datasets
from torchvision.transforms import v2
import torchvision.models as models

learning_rate=1e-3
batch_size=64
epochs =5

def train_loop(dataloader,model,loss_fn,optimizer):
    size=len(dataloader.dataset)
    model.train()
    for batch,(X,y) in enumerate(dataloader):
        pred=model(X)
        loss=loss_fn(pred,y)

        loss.backward()
        optimizer.step()
        optimizer.zero_grad()

        if batch%100==0:
            loss,current=loss.item(),batch*batch_size+len(X)
            log.info(f"loss: {loss:>7f} [{current:>5d}/{size:>5d}]")


def test_loop(dataloader,model,loss_fn):
    model.eval()
    size=len(dataloader.dataset)
    num_batches=len(dataloader)
    test_loss,correct=0,0
    with torch.no_grad():
        for X,y in dataloader:
            pred=model(X)
            test_loss+=loss_fn(pred,y).item()
            correct+=(pred.argmax(1)==y).type(torch.float).sum().item()

    test_loss /= num_batches
    correct /= size
    log.info(f"Test Error \n Accuracy:{(100*correct):>0.1f}%,Avg loss:{test_loss:>8f} \n")

class NeuralNetwork(nn.Module):
    def __init__(self):
        super().__init__()
        self.flatten=nn.Flatten()
        self.linear_relu_stack=nn.Sequential(
            nn.Linear(28*28,512),
            nn.ReLU(),
            nn.Linear(512,512),
            nn.ReLU(),
            nn.Linear(512,10)
        )
    
    def forward(self,x):
        x=self.flatten(x)
        logits=self.linear_relu_stack(x)
        return logits


def train():
    training_data=datasets.FashionMNIST(
        root=DATA_ROOT,
        train=True,
        download=False,
        transform=v2.Compose([v2.ToImage(),v2.ToDtype(torch.float32,scale=True)])
    )
    
    test_data=datasets.FashionMNIST(
        root=DATA_ROOT,
        train=False,
        download=False,
        transform=v2.Compose([v2.ToImage(),v2.ToDtype(torch.float32,scale=True)])

    )

    train_dataloader=DataLoader(training_data,batch_size=64)
    test_dataloader=DataLoader(test_data,batch_size=64)







    model=NeuralNetwork()

    # Initialize the loss function
    loss_fn = nn.CrossEntropyLoss()

    optimizer=torch.optim.SGD(model.parameters(),lr=learning_rate)


    epochs = 1
    for t in range(epochs):
        print(f"Epoch {t+1}\n-------------------------------")
        train_loop(train_dataloader, model, loss_fn, optimizer)
        test_loop(test_dataloader, model, loss_fn)
    print("Done!")
    torch.save(model, "m.pth")


if __name__ == "__main__":
    # train()
    model = torch.load("m.pth", weights_only=False)
    model.eval()










