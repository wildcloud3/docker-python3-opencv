#!/usr/bin/env python 
#coding:utf-8

import pytesseract
import cv2
import numpy as np
from PIL import Image
from flask import Flask, request, jsonify
from flask_cors import CORS, cross_origin

app = Flask('ocrServer')
URL = "http://www.tp-link.com.cn/content/images/detail/R50kit/1.jpg"
SUPPORTED_LANGS = ['eng', 'chi_sim']

cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

def preprocessImage(image):
    return image

def getImageFromRequestsRawBody(save_tmp_filename=None):
    image = np.asarray(bytearray(request.get_data()), dtype="uint8")
    image = cv2.imdecode(image, cv2.IMREAD_COLOR)

    if save_tmp_filename is not None:
        cv2.imwrite(save_tmp_filename, image)

    return image

# image is cv2,np format
def ocrIt(lang, image):
    return  pytesseract.image_to_string(image,lang=lang)

@app.route("/ocr", methods=['OPTIONS'])
def ocrDesc():
    return jsonify({
        'METHOD': 'POST',
        'URL_PARAMETER': [{
            'key': 'lang',
            'available choice': SUPPORTED_LANGS
        }],
        'DESC': 'post image binary to server directly please'
    })

@app.route("/ocr", methods=['POST'])
@cross_origin()
def ocrImage():
    lang = request.args.get('lang', default = 'chi_sim', type = str)

    if lang not in SUPPORTED_LANGS:
        return 'lang {0} not supported'.format(lang)

    image = getImageFromRequestsRawBody()
    image = preprocessImage(image)
    ocr_string = ocrIt(lang, image)
    return ocr_string

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=False)
