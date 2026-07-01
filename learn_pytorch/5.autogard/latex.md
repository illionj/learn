$
p= \sigma(z) = \frac{1}{1+e^{-z}}
$


$
L = -\left(y\log p + (1-y)\log(1-p)\right)
$


$
\frac{\partial {L}}{\partial{z}}=\frac{\partial{L}}{\partial{p}} \cdot \frac{\partial{p}}{\partial {z}}
$

$
\frac{\partial {L}}{\partial {p}}=-(\frac {y}{p} - \frac{1-y}{1-p}) 
$

$
\frac{\partial {p}}{\partial{z}}=\frac{e^{-z}}{(1+e^{-z})^2}
$

$
\frac{\partial{L}}{\partial{z}}=-(\frac {y}{p} - \frac{1-y}{1-p}) \cdot \frac{e^{-z}}{(1+e^{-z})^2}=p-y
$

$
p_i=\sigma(\frac{1}{1+e^{-z_i}})
$

$
\ell_i = -(y_i\log{p_i}+(1-y_i)\log{(1-p_i)})
$

$
L=\frac{1}{N}\sum_{i=1}^{N}\ell_i
$

$
\frac {\partial{L}}{\partial{z_i}}=\frac {1}{N}(p_i-y_i)
$

$
\frac{\partial L}{\partial w_{ij}}
$
和
$
\frac{\partial L}{\partial b_i}
$

$
\frac{\partial z_j}{\partial w_{ij}}=x_i ,
\frac{\partial z_j}{\partial b_j}=1
$

$
\frac{\partial L}{\partial w_{ij}}=\frac {\partial{L}}{\partial{z_j}} \cdot \frac{\partial z_j}{\partial w_{ij}}= \frac {x_i}{N}(p_j-y_j) 
$

$
\frac{\partial L}{\partial b_{j}}=\frac {\partial{L}}{\partial{z_j}} \cdot \frac{\partial z_j}{\partial b_{j}}= \frac {1}{N}(p_j-y_j)
$

如果只从我们的例子出发,计算到这里即可(因为我们已经拿到了所有变量的梯度)

但是如果当前的例子只是一层,我们需要进一步计算,每一个x_i都是上一层的输出,反向传播时上层也需要梯度的流转

一个想当然的思路(很遗憾是错误的,因为我就犯了这个错)
$
\frac {\partial L}{\partial x_i}=\frac {\partial L}{\partial z_i} \cdot \frac{\partial z_i}{\partial x_i}
$
正确思路是回到表达式
$
z=xW+b
$
并且
$
z_j=\sum_{i=1}^{N}x_{i}W_{ij}+b_j
$

这里能看到一个明显的信号,那就是无论对哪个z_j求值,都需要所有x_i参与(矩阵乘法)
因此,按照线性映射的特点,我们需要从所有的$\frac {\partial{L}}{\partial{z_j}}$"采集"x_i对L的影响

所以正确的表达式应该是这样:
$
\frac {\partial L}{\partial x_i}=\sum_{j=1}^{N}\frac {\partial L}{\partial z_j} \cdot \frac{\partial z_j}{\partial x_i}
$

接着再看看 $\frac{\partial z_j}{\partial x_i}$应该如何表示

$
\frac{\partial z_j}{\partial x_i}=W_{ij}
$

所以

$
\frac {\partial L}{\partial x_i}=\sum_{j=1}^{N}\frac {\partial L}{\partial z_j} \cdot \frac{\partial z_j}{\partial x_i}=\sum_{j=1}^{N}\frac {1}{N}(p_j-y_j) \cdot W_{ij}
$

这时引入记号,表示loss 对当前层输出的梯度,也就是从后面传回来的梯度
$
\delta=\frac {\partial L}{\partial z_j}
$

通常也记为
$
\delta^{l}=\frac {\partial L}{\partial z^l}
$
其中l表示第l层
$z^l$表示该层的linear output (activation之前)

这时,线性层:
$
\frac{\partial L}{\partial w_{ij}}=\frac {\partial{L}}{\partial{z_j}} \cdot \frac{\partial z_j}{\partial w_{ij}}= \frac {x_i}{N}(p_j-y_j) = x_i \delta_j
$

输入梯度:
$
\frac {\partial L}{\partial x_i}=\sum_{j=1}^{N}\delta_{j}W_{ij}
$

变成矩阵形式
$
\frac {\partial L}{\partial x}=\delta W^{T}
$

转置出现了
```
grad_input = grad_output @ W.T
```

一种非常奇妙的对偶结构也出现了
forward
$
z=xW
$

backward
$
dx=\delta W^{T}
$

forward 的 Jacobian：J
backward 做的是：$J^{T}v$

vector-Jacobian product

比如输入n,输出n
这种多元函数的导数是一个n*n矩阵
每一个节点存储一个n*n矩阵不经济也不现实
我们实际需要的只是当前这个节点的梯度
达到这个目标,不一定只能存储完整雅可比矩阵,才能完成计算
如果已知上游梯度,则只需要上游梯度 × 局部Jacobian即可
上游梯度再反向传播中流转,而局部jacobian和计算规则是在中间节点(计算方法)定义的时候就一并定义了
因此只要拿到上游梯度,再结合当前节点定义好的局部 Jacobian,就可以通过 VJP：计算出当前节点输入的梯度，并继续向前传播。




