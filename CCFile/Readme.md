

1.关于CCFile的使命和功能介绍
	CCFile 的英文全称：Copy and Check form embedded linux system. 
	这个脚本工具的意图是尽可能的帮助嵌入式工程师节约Dev和Debug的时间.
	它能够实现从目标板中快速检索和传送大批量指定的文件，并对文件进行校验.
	它的原理很简单，运行的目标环境为嵌入式linux，基于BusyBox运行，测试通过的版本为 BusyBox v1.22.1.

2.关于使用方法
	1.首先你需要配置一个cfg列表，其实就是列出你想从目标板get的文件名全称
	类似如此设置：
	Sample_cfg=(
		F---folder1   # CCFile Output file save folder location
			fileA
			fileB
			fileC
			fileD
			...
		F---folder2   # CCFile Output file save folder location
			fileA
			fileB
			fileC
			...
		F---....      # CCFile Output file save folder location
			...
			...
		F---folderN
		 	fileA
			fileB
			...
	)
	其中“Sample_cfg”为你cfg的名字，这里你随你喜好而定~
	“F---” 后面跟着文件夹的名称，这个名称也是根据你的喜好而定，但是“F---” 这个label不能丢，
	设置文件夹的目的是为了方便对所需要copy的文件进行分类，当然你也可以不设置这些文件夹，
	然后就是把想要copy的文件名全称写到对应的文件下。

	2.注册你的cfg到target_cfg
	类似如此：target_cfg=(${Sample_cfg[@]}
	然后保存文件，关闭即可。

	3.运行CCFile.sh
	选择一种最适合你的方式将脚本upload到你的目标板，我这里举例使用 tftp:
		cd /tmp  # 对于read-only的系统，这里最适合了
		tftp -g -r CCFile.sh 192.168.0.103
	运行，运行时记住需要带上一个参数，你 TFTP Server 的地址：
		chmod 777 CCFile.sh
        ./CCFile.sh 192.168.0.103

    4.查看output
    运行完毕后CCFile会上传一包名为 CCFile_Output.tar.gz 的压缩档到你的TFTP Server 文件夹下
    解开文件夹，根目录有一个check.sum文件，里面保存的是目标文件的 md5sum 值，
    你可以将check.sum中的内容 Ctrl+A &&  Ctrl+C 到一个新建的excel表格中，方便你跟原始值比较，
    然后其他目录以及目录下的文件内容就是你在cfg中定义的啦！

    完毕！ 
