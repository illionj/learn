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

# autograd_backward_f 这是微分的原理,而不是自动微分的原理
# 我需要的是自动
# f(x,y,z)=(x+y)z    
def autograd_backward_f(x,y,z):
    q=x+y
    dff=1
    dfq=z
    dfz=q
    dqx=1
    dqy=1
    dfx=dff*dfq*dqx
    dfy=dff*dfq*dqy
    dfz=dff*dfz
    return [dfx,dfy,dfz]

    pass


# x = Value(2.0)
# y = Value(3.0)
# z = Value(4.0)

# f = (x + y) * z
# f.backward()

# print(x.grad, y.grad, z.grad)

# 第一步：只处理表达式，不处理“程序”
# 第二步：先手算局部导数，观察规律
# 第三步：发现“导数信息”可以反着流
# 第四步：把它抽象成通用规则
# z=x*y+y


# 如果一个节点能被理解为：

# (
# value
# ,
# dot
# )
# (value,dot)

# 并且它的 forward 只是把孩子的这两个量合成为自己的这两个量，那你基本就在做前向 AD 了。

from enum import Enum


# 符号微分
class Node1:
    def __init__(self):
        self.left:Node=None
        self.right:Node=None
        self.op:str=None
        self.value:float=None
        pass

    def eval(self):
        if self.op is None:
            return self.value
        else:
            if self.op == "mul":
                return self.left.eval() * self.right.eval()
            if self.op == "add":
                return self.left.eval() + self.right.eval()
# 感觉前向模式,确实一个不错的优化
# 但是多惊艳也没有很让人印象深刻,因为原始符号微分递归的时候完全可以先查询自己的dot
# 当然我只是从计算机工程的角度来评价


# 但 forward-mode 真正厉害的地方在：它可以自然推广到“方向导数”
# dot = (1, 2, 3)


# 原始的导数 y=f(x)  只能上涨或者下降,所以它的导数是一个标量,也可以定义成一维向量,正负表示上下
# 多元函数中的梯度,偏导数的集合是一个向量,向量的方向表示最大的增长方向,向量的数值表示增长的程度


# 方向导数 = 梯度 和 某个方向向量 的内积
# 👉 梯度是“所有方向变化率的全集”

# 👉 方向导数是“选一个方向后的投影”

# forward-mode 本质上算的不是“梯度”，
# 而是“方向导数”
# 如果把x.dot和y的dot分别进行设置
# 得到的就是沿(x.dot,y.dot)方向前进的变化率,如果它是单位向量,计算出来的就是方向导数
# 如果输入动一点，输出怎么变？”  这就是那个dot            
# forward
class Node:
    def __init__(self):
        self.left:Node=None
        self.right:Node=None
        self.op:str=None
        self.value:float=None
        self.dot:float=None
        pass

    def eval(self):
        if self.op is None:
            return self.value
        else:
            if self.op == "mul":
                return self.left.eval() * self.right.eval()
            if self.op == "add":
                return self.left.eval() + self.right.eval()
            
    def derivative(self,v):
        if self.op is None:
           if v == self:
               return 1.0
           else:
               return 0.0
        else:
            if self.op == "add":
                return self.left.derivative(v)+self.right.derivative(v)
            if self.op == "mul":
                return self.left.derivative(v)*self.right.eval()+self.left.eval()*self.right.derivative(v)

        pass




    def forward(self):
        if self.op is None:
            pass
        else:
            if self.op == "add":
                self.value=self.left.value+self.right.value
                self.dot= self.left.dot+self.right.dot
            if self.op == "mul":
                self.value=self.left.value*self.right.value
                self.dot= self.left.dot*self.right.value+self.left.value*self.right.dot
            

def test_forward():
    log.info("forward")
    x=Node()
    y=Node()
    a=Node()
    a.left=x
    a.right=y
    a.op="add"

    z=Node()
    z.left=a
    z.right=y
    z.op="mul"


    x.value=1.5
    x.dot=1.0
    y.value=-9.2
    y.dot=0.0

    a.forward()
    z.forward()


    log.info(f"z={z.eval()}")

    log.info(f"dzx={z.derivative(x)},dzy={z.derivative(y)}")
    log.info(f"z={z.value} dz dot={z.dot}")

            
class Node_back:
    def __init__(self):
        self.left:Node_back=None
        self.right:Node_back=None
        self.grad:float=0.0
        self.op:str=None
        self.value:float=None
        pass
    pass

            
    def forward(self):
        if self.op is None:
            pass
        else:
            if self.op == "add":
                self.value=self.left.value+self.right.value
            if self.op == "mul":
                self.value=self.left.value*self.right.value
      
            
    def backward(self):
        if self.op == "add":
            self.left.grad+=self.grad*1.0
            self.right.grad+=self.grad*1.0
            pass
        if self.op == "mul":
            self.left.grad+=self.grad*self.right.value
            self.right.grad+=self.grad*self.left.value
            
            pass



def test_backward():
    log.info("backward")
    x=Node_back()
    y=Node_back()
    a=Node_back()
    a.left=x
    a.right=y
    a.op="add"

    z=Node_back()
    z.left=a
    z.right=y
    z.op="mul"

    x.value=1.5
    y.value=-9.2

    z.grad=1

    a.forward()
    z.forward()

    z.backward()
    a.backward()


    log.info(f"dzx={x.grad} dzy={y.grad}")


    pass
        

if "__main__" ==__name__:
    log.info("autograd")
    test_forward()
    test_backward()



# # 为什么反向模式能一次拿到所有输入的梯度，而前向模式通常一次只适合一个方向。
# 因为前向模式其实算的是方向导数,方向导数的方向向量和梯度的内积
# 所以我们设置前向模式的方向比如 (1,0) 或者(0,1) 相当于将梯度投影到坐标轴上得到梯度在某个分量上的值
# 因此一次算一个

# 反向模式则是

# #
# # 为什么 reverse mode 反传时，每个节点存的是“最终输出对我”的敏感度，而不是“我对最终输出”的某种别的东西？
# # 语义不一样 这样存到最后不是dz/dx而是dx/dy

# 只从形式上来看会有种导数的感觉
# 但实际不可行,因为对于一维函数,如果函数可逆,那么它是倒数关系
# 对于多元函数在多变量情况下，这种关系基本不存在

# dz/dx x对z的影响
# dx/dz z对x的影响,z对x的可以没影响,也可以有影响,类似线性规划中的z=x+y  z增加或减少,可能与x相关也可能无关
# 通常增加额外条件,可能转化成一个优化问题 




# # 为什么反向模式能一次拿到所有输入的梯度，而前向模式通常一次只适合一个方向。
# 因为前向模式其实算的是方向导数,方向导数的方向向量和梯度的内积
# 所以我们设置前向模式的方向比如 (1,0) 或者(0,1) 相当于将梯度投影到坐标轴上得到梯度在某个分量上的值
# 因此一次算一个

# reverse-mode 则是从输出出发，把输出的变化分解到每一个输入变量上，
# 得到每个输入对输出的贡献，因此可以一次性得到所有偏导数，也就是完整梯度


