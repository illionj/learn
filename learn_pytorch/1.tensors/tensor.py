import sys
from pprint import pformat

from pathlib import Path

import torch
import numpy as np

PROJECT_ROOT = Path(__file__).resolve().parents[2]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from learn_pytorch.common import get_logger



log = get_logger("tensor", console_style="simple", enable_file=False)

data=[[1,2],[3,4]]

x_data=torch.tensor(data)

log.debug("raw data: {}", data)
log.info("tensor shape: {}", tuple(x_data.shape))
log.info(pformat(x_data))

np_array=np.array(data)
log.info("np_array={}",np_array)
x_np=torch.from_numpy(np_array)
log.info("x_np={}",x_np)


x_ones=torch.ones_like(x_data)
log.info(f"one tensor: \n {x_ones} \n")
x_rand=torch.rand_like(x_data,dtype=torch.float)
log.info(f"random tensor: \n {x_rand} \n")

shape=(2,3,)
rand_tensor=torch.rand(shape)
ones_tensor=torch.ones(shape)
zeros_tensor=torch.zeros(shape)

log.info(rand_tensor)
log.info(ones_tensor)
log.info(zeros_tensor)


tensor=torch.rand(3,)
log.info(tensor)

log.info(tensor.shape)
log.info(tensor.dtype)
log.info(tensor.device)

log.info(torch.accelerator.is_available())

log.info("------------------------------------------------")
tensor=torch.ones(4,4,)


# 如何按照某种规则初始化torch tensor
# 我的解法
tensor=torch.tensor([x for x in np.arange(16)])
tensor=tensor.reshape(4,4,)
#最佳实践
tensor=torch.arange(16).reshape(4,4)

#扩展最佳实践  假设已有一个形状  最佳实践就是先按照上面准备好自变量,然后使用
#y=f(x)
#比如:
tensor=torch.arange(16)
# y=torch.sin(tensor)
y=2*tensor+1
tensor=y.reshape(4,4)

# 更加虎书对于优化的理解,压缩流程会有更好的效果(相当于透露更多信息给解释器/编译器)
tensor= (torch.arange(24)).reshape(2, 3,4)

log.info(f"first x: {tensor[0]}")
log.info(f"first y: {tensor[:,0,...]}")
log.info(f"first z: {tensor[...,0]}")

log.info(tensor[0,0,2])

# 最后一列? 这里其实表示的是第一个维度取所有,第二个维度取最后一个元素 (因为是2*2矩阵,所有也是最后一列)
log.info(f"last column1:{tensor[:,-1]}")
log.info(f"last column2:{tensor[...,-1]}")

#  所以说维度和进制很像  比如这个shape=(2,3,4,)
# permute view stride
#  
# 我还是觉得困惑,因为我很难去理解一个tensor,它有大于2个维度,然后交换维度,得到的那个结果
# 甚至固定某个维度比如 tensor[:,1,:]
# 这个东西到底是什么玩意

# 应该彻底放弃空间概念,三维想象力有限,高维不可想象

# 对于一批RGB图像，尺寸为（B=10, C=3, H=256, W=256）

# 有4个维度 分别是第(0,1,2,3)维
# 现在的解释是我有个10张图片三个通道,每个通道有256行,每行有256像素
# 现在交换维度 
# 0-B-图片，1-C-通道，2-H-行，3-W-像素 
# 如果执行tensor.permute(0, 2, 3, 1)操作，我们就需要序号变成0 2 3 1，
# 那么只要直接挪动顺序即可：（0-B-图片，2-H-行，3-W-像素，1-C-通道）

# 我用10张图片,每个图片有256行,每行有256个像素,每个像素有3个通道

# 那么当我固定某个维度是,在（B=10, C=3, H=256, W=256）下只考量通道0
# 我得到的是10个图片中,所有的0的通道下的256行和256个像素


# (0,1,2,3)->3  0 1  2
# 不行这种方式也无法理解,也就是说tensor的变换全部合法但很难给每种变换都给一个合理解释

# 每个tensor 的shape都是(2,3,4,) 数值就是0->23  注释中的+  表示拼接
log.info("-----------cat-----------------------")
# [
#   tensor[0],
#   tensor[1],
#   tensor[0],
#   tensor[1]
# ]
t1=torch.cat([tensor,tensor],dim=0)
log.info(t1)
log.info(t1.shape)

# [
#   tensor[0] + tensor[0],
#   tensor[1] + tensor[1]
# ]
t1=torch.cat([tensor,tensor],dim=1)
log.info(t1)
log.info(t1.shape)

# [
#   [
#     tensor[0][0] + tensor[0][0],
#     tensor[0][1] + tensor[0][1],
#     tensor[0][2] + tensor[0][2]
#   ],
#   [
#     tensor[1][0] + tensor[1][0],
#     tensor[1][1] + tensor[1][1],
#     tensor[1][2] + tensor[1][2]
#   ]
# ]
t1=torch.cat([tensor,tensor],dim=2)
log.info(t1)
log.info(t1.shape)

# 每个tensor 的shape都是(2,3,4,) 数值就是0->23
log.info("-----------stack-----------------------")
# [
#   tensor,
#   tensor
# ]
t1=torch.stack([tensor,tensor],dim=0)
log.info(t1)
log.info(t1.shape)
# [
#   [
#     tensor[0],
#     tensor[0]
#   ],
#   [
#     tensor[1],
#     tensor[1]
#   ]
# ]
t1=torch.stack([tensor,tensor],dim=1)
log.info(t1)
log.info(t1.shape)
# [
#   [
#     [
#       tensor[0][0],
#       tensor[0][0]
#     ],
#     [
#       tensor[0][1],
#       tensor[0][1]
#     ],
#     [
#       tensor[0][2],
#       tensor[0][2]
#     ]
#   ],
#   [
#     [
#       tensor[1][0],
#       tensor[1][0]
#     ],
#     [
#       tensor[1][1],
#       tensor[1][1]
#     ],
#     [
#       tensor[1][2],
#       tensor[1][2]
#     ]
#   ]
# ]
t1=torch.stack([tensor,tensor],dim=2)
log.info(t1)
log.info(t1.shape)
# [
#   [
#     [
#       [tensor[0][0][0], tensor[0][0][0]],
#       [tensor[0][0][1], tensor[0][0][1]],
#       [tensor[0][0][2], tensor[0][0][2]],
#       [tensor[0][0][3], tensor[0][0][3]]
#     ],
#     [
#       [tensor[0][1][0], tensor[0][1][0]],
#       [tensor[0][1][1], tensor[0][1][1]],
#       [tensor[0][1][2], tensor[0][1][2]],
#       [tensor[0][1][3], tensor[0][1][3]]
#     ],
#     [
#       [tensor[0][2][0], tensor[0][2][0]],
#       [tensor[0][2][1], tensor[0][2][1]],
#       [tensor[0][2][2], tensor[0][2][2]],
#       [tensor[0][2][3], tensor[0][2][3]]
#     ]
#   ],
#   [
#     [
#       [tensor[1][0][0], tensor[1][0][0]],
#       [tensor[1][0][1], tensor[1][0][1]],
#       [tensor[1][0][2], tensor[1][0][2]],
#       [tensor[1][0][3], tensor[1][0][3]]
#     ],
#     [
#       [tensor[1][1][0], tensor[1][1][0]],
#       [tensor[1][1][1], tensor[1][1][1]],
#       [tensor[1][1][2], tensor[1][1][2]],
#       [tensor[1][1][3], tensor[1][1][3]]
#     ],
#     [
#       [tensor[1][2][0], tensor[1][2][0]],
#       [tensor[1][2][1], tensor[1][2][1]],
#       [tensor[1][2][2], tensor[1][2][2]],
#       [tensor[1][2][3], tensor[1][2][3]]
#     ]
#   ]
# ]
t1=torch.stack([tensor,tensor],dim=3)
log.info(t1)
log.info(t1.shape)



# cat是将指定的维度拼接在一起(construct)
# 1.如果由n个维度 cat最大只能指定拼接n-1维(在n-1维发生拼接,拼接的是n维),显而易见不能指定到n维
# 2.对于0维 m维 n-1维 都是在指定维度处按照顺序拼接后面一维的数据
# 3.cat拼接,被指定的维度可以不同,其他维度必须相同

# cat是将指定的维度拼接在一起(construct)

# 如果有 n 个维度，cat 只能指定 0 ~ n-1 维（因为只能在已有维度上拼接，不能指定到 n 维）

# 对于 0 维 / m 维 / n-1 维，都是在指定维度本身进行拼接，即该维度长度变长，其他维度不变（不是拼接后面一维的数据）

# cat拼接时，被指定的维度可以不同，其他维度必须相同

# stack是将指定的维度抽出来但作为一维
# 1.所以stack能指定0-n维
# 2.对于0维,就是套一个大壳子将东西装起来,对于n维,就是将最后那个独立元素和其他要打包的tensor的独立元素打包成一个新维度
# 对于m维(0<m<n,且n>1) m前面的东西不变,m维会和其他tensor的m维打包在一起,里面内容不变
# 3.stack维度shape必须完全一致

# stack是将多个tensor在指定位置新增一个维度，并在该维度上进行打包

# 所以 stack 可以指定 0 ~ n 维（因为是新增维度）

# 对于 0 维：就是套一个大壳子将东西装起来

# 对于 n 维：就是将最内层的元素与其他tensor对应元素打包成一个新维度

# 对于 m 维（0 < m < n，且 n > 1）：m 前面的结构不变，在第 m 维位置新增一层，该层用于放不同 tensor，对应位置的数据内容本身不变

# stack 时，所有 tensor 的 shape 必须完全一致




