# CoreML
    苹果官网给出了几种机器学习算法模型转化为mlmodel的文件，我选取了第一种。
    因为发现苹果基于每种model都做了一层封装，定义了一个输入类，和一个输出类。
    model文件挺大的，最近在看关于机器学习的知识，mlmodel也有python脚本去生成，
    苹果封装的一层挺清晰易懂的，下面是输入和输出。
    demo里面我写了一个相机入口作为输入源，得到的实时的图片image，然后转化为MobileNetInput，
    输出MobileNetOutput。
    
    MobileNetInput *input = [[MobileNetInput alloc] initWithImage:buffer];
    MobileNetOutput *output = [mobileNet predictionFromFeatures:input error:&error];

    MobileNetOutput中有一个classlabel
    /// Most likely image category as string value
    @property (readwrite, nonatomic) NSString * classLabel;
    
    可以实时并且炒准确的识别出图片里面的物体分类
