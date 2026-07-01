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
log=get_logger("transforms",console_style="simple",enable_file=False)
DATA_ROOT=PROJECT_ROOT.joinpath("data")


import torch 
from torchvision import datasets
from torchvision .transforms import ToTensor,Lambda

if __name__ =="__main__":

    log.info("transform")
    log.info(f"DATA_ROOT={DATA_ROOT}")
    ds=datasets.FashionMNIST(
        root=DATA_ROOT,
        train=True,
        download=True,
        transform=ToTensor(),
        target_transform=Lambda(lambda y: torch.zeros(10,dtype=torch.float).scatter_(dim=0,index=torch.tensor(y),value=1))
    )


    img,lable=ds[0]
    log.info(f"label={lable}")

    log.info("transform end")