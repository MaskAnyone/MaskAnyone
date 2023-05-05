# This script groups images or masks with the same id (class) in a folder and splits for train and test.
# To group images in folders a txt with the corresponding file name and class is required

import math
import shutil
import os

d = {}
p = "/home/rohan/Documents/Uni/Sem4/MP/Datasets/identity_CelebA.txt"
in_masks = "/home/rohan/Documents/Uni/Sem4/MP/TowardsMultimodalOpenScience/out_images"
out_f = "/home/rohan/Documents/Uni/Sem4/MP/TowardsMultimodalOpenScience/masks_grouped4"
file1 = open(p, 'r')
for line in file1.readlines():
    img_p, group = line.split()
    if group in d:
        d[group].append(img_p)
    else:
        d[group] = [img_p]
count = 0
for k in d.keys():
    if count == 80:
        break
    if len(d[k]) <= 4:
        continue
    train = d[k][:math.floor(0.7*len(d[k]))]
    test = d[k][math.floor(0.7*len(d[k])):]
    for f in train:
        src = os.path.join(in_masks, f)
        if os.path.exists(src):
            if not os.path.exists(os.path.join(out_f, "train", k)):
                os.mkdir(os.path.join(out_f, "train", k))
            dest = os.path.join(out_f, "train", k, f)
            shutil.copyfile(src, dest)
            if not os.path.exists(os.path.join(out_f, "database_set", k)):
                os.mkdir(os.path.join(out_f, "database_set", k))
            dest = os.path.join(out_f, "database_set", k, f)
            shutil.copyfile(src, dest)
    for f in test:
        src = os.path.join(in_masks, f)
        if os.path.exists(src):
            if not os.path.exists(os.path.join(out_f, "eval", k)):
                os.mkdir(os.path.join(out_f, "eval", k))
            dest = os.path.join(out_f, "eval", k, f)
            shutil.copyfile(src, dest)
    count += 1