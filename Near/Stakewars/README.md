NEAR测试网跑验证人节点的任务，总共9个任务, 时间从7/13 到9/7

任务：https://github.com/near/stakewars-iii/tree/main/challenges

任务表格(4-8): https://docs.google.com/forms/d/e/1FAIpQLScp9JEtpk1Fe2P9XMaS9Gl6kl9gcGVEp3A5vPdEgxkHx3ABjg/viewform

项目介绍：https://near.org/stakewars/

Discord: https://discord.gg/2zaHJz5M


完成任务有的获得UNP奖励，有的获得DNP奖励

UNP在测试网结束的时候，可以1:1换取主网的NEAR
DNP在测试网结束的时候，会按1:500 NEAR的比例，获得项目方质押，为期1年


![image.png](https://cdn.steemitimages.com/DQmeSWJpayNvmzHishdFBhdLCX5fYvq7h3y2hmYPauSWVgP/image.png)

虽然有9个任务，但是需要提交的就任务5-8

官方的文档写的挺清楚的，可以按照步奏一步步完成。如果想快速完成，可以使用我写的自动安装的脚本（完成1-6）

我用的服务器是Hetzner的AMD Ryzen 5 3600，一个月34欧元


![image.png](https://cdn.steemitimages.com/DQmRUyaQYiCA8Qyp8tfRLgPFRUrv32VaaFkwBMJyAkztVWw/image.png)

运行Near节点绰绰有余，大家可以考虑其他的VPS，比如contabo的Cloud VPS M, 一个月8.99欧元，同样能跑起节点

![image.png](https://cdn.steemitimages.com/DQmcPbmURaoQT1RPAXySXW9xUjwpUfuiajzwS9himnQR3G5/image.png)



## 自动安装版
建议Ubuntu系统，运行以下命令:
~~~
curl -s https://raw.githubusercontent.com/ericet/easynodes/master/Near/Stakewars/install.sh > stakewars.sh && sudo chmod +x stakewars.sh && ./stakewars.sh
~~~

![image.png](https://cdn.steemitimages.com/DQmSug8nobpjqbPKFvnQkLj1Nxa9oY5WrHEhgQKEmPoPpgx/image.png)

先输入1查看服务器是否符合官方要求的配置，如果符合，可以继续按照顺序选择操作。



![image.png](https://cdn.steemitimages.com/DQmbSn45g97eZirjJdxaEuVVnTT9dqy64z3HkNP14BBuomk/image.png)

环境和节点都安装好后，输入4 开始设置节点


![image.png](https://cdn.steemitimages.com/DQmYZWXdr4jPUsPHPAP9Xd1Wagh6WUGKw4eLLmr1nesev2d/image.png)

复制生成的授权链接到浏览器。

如果你已经创建过钱包，可以导入。如果没有就新建一个

![image.png](https://cdn.steemitimages.com/DQmYhMt4KSysaPqUNYjYuvGWrFQ7iA9r4PNdL4eyfY46J4Z/image.png)


搞定钱包后，就可以进行授权


![image.png](https://cdn.steemitimages.com/DQmVx7qKuqs9NgWPzm5DV4Bv2k2g73gEumBZTtvXLTuM1vN/image.png)


授权完成后，回到服务器，输入刚进行授权的钱包

![image.png](https://cdn.steemitimages.com/DQmdZk9Nmp6pCWTFVNa6UjYHCpQWkcbkAE1Txk1Q96JU4RA/image.png)


再次输入钱包


![image.png](https://cdn.steemitimages.com/DQmPaPanyJ7bjoRCwEjEC73QGmGn6kXUpATPyrhk9QDV6Ps/image.png)

输入Pool ID （比如 xxxx.factory.shardnet.near)

![image.png](https://cdn.steemitimages.com/DQmPprRqZMEaCWEvVeRGisk4RwHz6CtY7Vemk1S4zuvYcd6/image.png)

按照要求填入Public Key和Private Key
![image.png](https://cdn.steemitimages.com/DQmbeMjju6uiEfDJAG7nAYRQgsWxWY7kmKGhz5kRrEmyvtU/image.png)

给池子取个名字，输入抽成比例和质押数量

![image.png](https://cdn.steemitimages.com/DQmbtysBoo7TNv2xMDK8EU82GRbft9JcY7qUVbCXkMW7BCV/image.png)


到这里节点的设置就完成了

你可以输入5查看PING的日志（5分钟运行一次)，或者6查看节点同步的情况


等节点运行一段时间后，可以去浏览器查看PING的记录，截图提交到表格就完成了挑战6

池子的浏览器链接(xxxx改成你的pool ID):
https://explorer.shardnet.near.org/accounts/xxxx.facotry.shardnet.near


![image.png](https://cdn.steemitimages.com/DQmTqsVqtrQV5gVsU5sRaQA5pNj5pi3SQEpgthzNNPaetf3/image.png)


挑战5是写文章介绍弄节点的过程，这一个自己来
