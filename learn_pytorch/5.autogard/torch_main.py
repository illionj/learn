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

import torch


def main():
    x=torch.ones(5)
    y=torch.zeros(3)
    w=torch.randn(5,3,requires_grad=True)
    b=torch.randn(3,requires_grad=True)
    z=torch.matmul(x,w)+b
    log.info(z.requires_grad)
    # 直接用于计算二分类交叉熵损失，并在内部自动完成 sigmoid + BCE，数值更稳定。
    # \sigma(x) = \frac{1}{1+e^{-x}}
    loss=torch.nn.functional.binary_cross_entropy_with_logits(z,y)
    log.info(f"Gradient function for z={z.grad_fn}")
    log.info(f"Gradient function for loss = {loss.grad_fn}")
    loss.backward()
    log.info(w.grad)
    log.info(b.grad)



if __name__ == "__main__":
    log.info("main2")
    main()



