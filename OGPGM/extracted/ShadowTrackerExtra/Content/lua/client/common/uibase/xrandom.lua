--sami 随机数生成器
XRandom = XRandom or
{
    _next = os.time();
    _magic1 = 1103515245;
    _magic2 = 12345;
    _magic3 = 65536;
}


--范围[0, 65536)
function XRandom.Random()
    XRandom._next = XRandom._next * XRandom._magic1 + XRandom._magic2;
    return math.ceil(XRandom._next / XRandom._magic3) % XRandom._magic3;
end


--范围[nMin, nMax)
function XRandom.Random2(nMin, nMax)
    local num = XRandom.Random()
    return nMin + num % (nMax - nMin);
end


