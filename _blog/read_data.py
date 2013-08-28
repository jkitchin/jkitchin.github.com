import matplotlib.pyplot as plt
import matplotlib.image as mpimg

img=mpimg.imread('images/eos.png')

plt.imshow(img)
plt.gray()
plt.show()

# get x-axis. We want 2 points, with the x-values
X = []
PX = []

for i in range(2):
    print('Click on the x-axis at a point')
    plt.show()
    px = plt.ginput(n=1)
    x = raw_input('Enter the x-value you just clicked on: ')
    X += [float(x)]
    PX += (px,)
    
    