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
from torchvision import datasets,transforms

class NeuralNetwork(nn.Module):
    def __init__(self):
        super().__init__()
        self.flatten=nn.Flatten()
        self.linear_relu_stack=nn.Sequential(
            nn.Linear(28*28,512),
            nn.ReLU(),
            nn.Linear(512,512),
            nn.ReLU(),
            nn.Linear(512,10),
        )
    def forward(self,x):
        x=self.flatten(x)
        logits=self.linear_relu_stack(x)
        return logits

if __name__ =="__main__":
    log.info("build model")
    device=torch.accelerator.current_accelerator().type if torch.accelerator.is_available() else "cpu"
    log.info(f"using {device} device")
    model=NeuralNetwork().to(device)
    log.info(model)

    X=torch.rand(2,28,28,device=device)
    logits=model(X)
    log.info(f"logits={logits}")
    pred_probab=nn.Softmax(dim=1)(logits)
    y_pred=pred_probab.argmax(1)
    log.info(f"predicted class: {y_pred}")

    input_image=torch.rand(3,28,28)
    flatten=nn.Flatten()
    flat_image=flatten(input_image)
    log.info(input_image.size())
    log.info(flat_image.size())
    log.info(len(flat_image))

    layer1=nn.Linear(in_features=28*28,out_features=20)
    hidden1=layer1(flat_image)
    log.info(hidden1)

    hidden1=nn.ReLU()(hidden1)
    log.info(f"after \n {hidden1}")

    log.info(f"model structure :{model} \n\n")

    for name,param in model.named_parameters():
        log.info(f"layer: {name} | size:{param.size()} |values: {param[:2]} \n")

# 这章主要是熟悉api,说到底还是对神经网络知识知之甚少,所以连问题都问不出来
 

