from PIL import Image
from collections import Counter
from scipy.spatial import KDTree
from sys import argv
import numpy as np

def convert_int_to_hexstr(val):
	if(val == 0):
		return '0'
	return str(hex(val)).lstrip("0x")

def get_max_count(ranking):
	max_color = ""
	max_count = 0
	for key in ranking:
		if(ranking[key] > max_count):
			max_color = key
			max_count = ranking[key]
	return max_color

# list of rgb
def same_color_check(color1, color2):
	if(color1[0] == color2[0]):
		if(color1[1] == color2 [1]):
			if(color1[2] == color2[2]):
				return True
	return False

def closest_color(pallete, pixel):
	best_color = 0
	min_dist = 255**2 + 255**2 + 255**2
	for idx in range(len(pallete)):
		test_dist = ((pallete[idx][0] - pixel[0])**2 + (pallete[idx][1] - pixel[1])**2 + (pallete[idx][2] - pixel[2])**2)
		if test_dist <= min_dist:
			min_dist = test_dist
			best_color = idx
	return best_color

def palletize_background_8(File, colors):
	pallete = [[121,202,249],
				[127,172,113],
				[244,247,252],
				[230,229,243],
				[176,231,103],
				[186,220,219],
				[106,146,242],
				[184,225,247]]
	colors_str = []
	for pixel in colors:
		best_color = closest_color(pallete, pixel)
		# hexstr = convert_int_to_hexstr(best_color[0]) + convert_int_to_hexstr(best_color[1]) + convert_int_to_hexstr(best_color[2])
		hexstr = convert_int_to_hexstr(best_color)
		colors_str.append(hexstr)
		File.write("3'h" + hexstr + ',\n')

	return colors_str

def main():
	if(len(argv) < 2):
		print "Usage: [script.py] [filename-to-convert]"
		return

	filename = argv[1]

	im = Image.open(filename + ".png") #Can be many different formats.
	im = im.convert("RGBA")
	colors_str = []
	colors_int = []

	outImg = Image.new('RGB', im.size, color='white')
	outFile = open(filename + '.txt', 'w')
	for y in range(im.size[1]):
	    for x in range(im.size[0]):
	        pixel = im.getpixel((x,y))
	        # print(pixel)
	        outImg.putpixel((x,y), pixel)
	        r, g, b, a = im.getpixel((x,y))
	        # outFile.write("%x%x%x\n" %(r,g,b))
	        colors_int.append([r, g, b])

	check = palletize_background_8(outFile, colors_int)
	outFile.close()
	outImg.save(filename+ ".png")

	print len(set(check)) # number of colors used
	print set(check) # colors used
	return

if __name__ == '__main__':
	main()
