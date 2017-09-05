# CoreML
    MobileNetInput *input = [[MobileNetInput alloc] initWithImage:buffer];
    MobileNetOutput *output = [mobileNet predictionFromFeatures:input error:&error];

    MobileNetOutput中有一个classlabel
    /// Most likely image category as string value
    @property (readwrite, nonatomic) NSString * classLabel;
    
