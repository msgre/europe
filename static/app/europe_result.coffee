# Screen #7, Result / Vysledek, Zadani jmena
#

App.module "Result", (Mod, App, Backbone, Marionette, $, _) ->

    Mod.startWithParent = false

    # --- constants & variables

    NAME_MAX_LENGTH = 16 + 1
    LETTER_BACKSPACE = '←'
    LETTER_ENTER = '✔'
    SVG = 
        rekord: '<svg width="80px" height="58px" viewBox="0 0 40 29" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"> <!-- Generator: Sketch 3.6 (26304) - http://www.bohemiancoding.com/sketch --> <title>rekord</title> <desc>Created with Sketch.</desc> <defs></defs> <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd"> <g id="ikony" transform="translate(-1.000000, -1.000000)" fill="#FFFFFF"> <g id="rekord" transform="translate(0.820513, 0.599998)"> <path d="M20.1025641,5.49700405 C13.4292103,5.49700405 8,10.8547773 8,17.4403239 C8,24.0258704 13.4292103,29.3836437 20.1025641,29.3836437 C26.7759179,29.3836437 32.2051282,24.0258704 32.2051282,17.4403239 C32.2051282,10.8547773 26.7759179,5.49700405 20.1025641,5.49700405 L20.1025641,5.49700405 Z M20.1025641,27.9504453 C14.2299159,27.9504453 9.45230769,23.2357004 9.45230769,17.4403239 C9.45230769,11.6449474 14.2299159,6.93020243 20.1025641,6.93020243 C25.9752123,6.93020243 30.7528205,11.6449474 30.7528205,17.4403239 C30.7528205,23.2357004 25.9752123,27.9504453 20.1025641,27.9504453 L20.1025641,27.9504453 Z" id="Shape"></path> <path d="M27.2271015,16.7237247 L20.795799,16.7237247 L20.795799,8.33664777 C20.795799,7.95876113 20.4854892,7.65253441 20.1025641,7.65253441 C19.719639,7.65253441 19.4088451,7.95876113 19.4088451,8.33664777 L19.4088451,17.4403239 C19.4088451,17.6815789 19.5361641,17.8927368 19.7273846,18.0145587 C19.8479262,18.1029393 19.9960615,18.1569231 20.1582359,18.1569231 L27.2271015,18.1569231 C27.6279385,18.1569231 27.9532554,17.8363644 27.9532554,17.4403239 C27.9532554,17.0442834 27.6279385,16.7237247 27.2271015,16.7237247 L27.2271015,16.7237247 Z" id="Shape"></path> <rect id="Rectangle-path" x="18.0054318" y="2.3248583" width="4.19523282" height="2.46796761"></rect> </g> </g> </g> </svg>'
        delete: '<svg width="30px" height="30px" viewBox="0 0 30 30" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"> <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd"> <g id="Group-2" transform="translate(-5.000000, -5.000000)"> <g id="delete" transform="translate(5.000000, 5.000000)"> <rect id="Rectangle-path" fill="#E30613" x="0.3125" y="0.204081633" width="29.375" height="28.9795918"></rect> <path d="M17.3158333,14.6946939 L23.88,8.26367347 C24.7325,7.43020408 24.905,6.24326531 24.2658333,5.61714286 C23.6233333,4.98938776 22.415,5.16163265 21.5641667,5.99755102 L15,12.4244898 L8.43583333,5.99755102 C7.58583333,5.16244898 6.37333333,4.99020408 5.73583333,5.61714286 C5.09416667,6.24408163 5.26666667,7.43102041 6.12166667,8.26367347 L12.6841667,14.6946939 L6.12166667,21.122449 C5.2675,21.9591837 5.095,23.1444898 5.73583333,23.7706122 C6.37416667,24.397551 7.58666667,24.2269388 8.43583333,23.3910204 L15,16.9608163 L21.5641667,23.3910204 C22.415,24.2261224 23.6233333,24.3967347 24.2658333,23.7706122 C24.9058333,23.1436735 24.7333333,21.9591837 23.88,21.122449 L17.3158333,14.6946939 L17.3158333,14.6946939 Z" id="Shape" fill="#FFFFFF"></path> </g> </g> </g> </svg>'
        left: '<svg width="38px" height="38px" viewBox="0 0 38 38" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"> <defs> <radialGradient cx="25.7596831%" cy="24.9239023%" fx="25.7596831%" fy="24.9239023%" r="84.4183208%" id="radialGradient-1"> <stop stop-color="#8C8C8C" offset="0%"></stop> <stop stop-color="#888888" offset="33.49%"></stop> <stop stop-color="#7D7D7D" offset="64.43%"></stop> <stop stop-color="#6B6B6B" offset="94.27%"></stop> <stop stop-color="#666666" offset="100%"></stop> </radialGradient> <radialGradient cx="72.7113911%" cy="76.8143067%" fx="72.7113911%" fy="76.8143067%" r="90.8730969%" id="radialGradient-2"> <stop stop-color="#8C8C8C" offset="0%"></stop> <stop stop-color="#888888" offset="33.49%"></stop> <stop stop-color="#7D7D7D" offset="64.43%"></stop> <stop stop-color="#6B6B6B" offset="94.27%"></stop> <stop stop-color="#666666" offset="100%"></stop> </radialGradient> </defs> <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd"> <g id="Group-2" transform="translate(-1.000000, -1.000000)"> <g id="left"> <g id="Group"> <g opacity="0.7" id="Shape" fill="#000000"> <path d="M0.831666667,19.5902041 C0.831666667,29.9461224 9.42833333,38.3697959 20.0016667,38.3697959 C30.57,38.3697959 39.1683333,29.9461224 39.1683333,19.5902041 C39.1683333,9.23591837 30.57,0.813877551 20.0016667,0.813877551 C9.42833333,0.813877551 0.831666667,9.23591837 0.831666667,19.5902041 L0.831666667,19.5902041 Z" opacity="0"></path> <path d="M38.8883333,19.5902041 C38.8883333,29.7959184 30.4166667,38.0955102 20.0016667,38.0955102 C9.58166667,38.0955102 1.11166667,29.7959184 1.11166667,19.5902041 C1.11166667,9.38612245 9.58166667,1.08816327 20.0016667,1.08816327 C30.4166667,1.08816327 38.8883333,9.38612245 38.8883333,19.5902041 L38.8883333,19.5902041 Z" opacity="0.1111"></path> <path d="M38.6083333,19.5902041 C38.6083333,29.6457143 30.2633333,37.8212245 20.0016667,37.8212245 C9.735,37.8212245 1.39083333,29.6457143 1.39083333,19.5902041 C1.39083333,9.5355102 9.73416667,1.36244898 20.0016667,1.36244898 C30.2633333,1.36244898 38.6083333,9.5355102 38.6083333,19.5902041 L38.6083333,19.5902041 Z" opacity="0.2222"></path> <path d="M38.3283333,19.5902041 C38.3283333,29.4971429 30.1108333,37.5469388 20.0016667,37.5469388 C9.8875,37.5469388 1.67083333,29.4971429 1.67083333,19.5902041 C1.67083333,9.68489796 9.8875,1.63673469 20.0016667,1.63673469 C30.1108333,1.63673469 38.3283333,9.68489796 38.3283333,19.5902041 L38.3283333,19.5902041 Z" opacity="0.3333"></path> <path d="M38.0483333,19.5902041 C38.0483333,29.3469388 29.9575,37.2718367 20.0016667,37.2718367 C10.0408333,37.2718367 1.95083333,29.3469388 1.95083333,19.5902041 C1.95083333,9.83510204 10.0408333,1.91102041 20.0016667,1.91102041 C29.9575,1.91102041 38.0483333,9.83510204 38.0483333,19.5902041 L38.0483333,19.5902041 Z" opacity="0.4444"></path> <path d="M37.7683333,19.5902041 C37.7683333,29.197551 29.8041667,36.997551 20.0016667,36.997551 C10.1933333,36.997551 2.23083333,29.1967347 2.23083333,19.5902041 C2.23083333,9.9844898 10.1941667,2.18530612 20.0016667,2.18530612 C29.805,2.18530612 37.7683333,9.9844898 37.7683333,19.5902041 L37.7683333,19.5902041 Z" opacity="0.5556"></path> <path d="M37.4883333,19.5902041 C37.4883333,29.0473469 29.6516667,36.7232653 20.0016667,36.7232653 C10.3466667,36.7232653 2.51,29.0473469 2.51,19.5902041 C2.51,10.1346939 10.3466667,2.46040816 20.0016667,2.46040816 C29.6516667,2.46040816 37.4883333,10.1346939 37.4883333,19.5902041 L37.4883333,19.5902041 Z" opacity="0.6667"></path> <path d="M37.2083333,19.5902041 C37.2083333,28.8979592 29.4983333,36.4489796 20.0016667,36.4489796 C10.5,36.4489796 2.79,28.8979592 2.79,19.5902041 C2.79,10.2840816 10.4991667,2.73469388 20.0016667,2.73469388 C29.4983333,2.73469388 37.2083333,10.2840816 37.2083333,19.5902041 L37.2083333,19.5902041 Z" opacity="0.7778"></path> <path d="M36.9283333,19.5902041 C36.9283333,28.7485714 29.345,36.1746939 20.0008333,36.1746939 C10.6516667,36.1746939 3.06916667,28.7477551 3.06916667,19.5902041 C3.06916667,10.4334694 10.6525,3.00816327 20.0008333,3.00816327 C29.3458333,3.00897959 36.9283333,10.4334694 36.9283333,19.5902041 L36.9283333,19.5902041 Z" opacity="0.8889"></path> <path d="M36.6491667,19.5902041 C36.6491667,28.5983673 29.1933333,35.9004082 20.0016667,35.9004082 C10.8058333,35.9004082 3.35,28.5983673 3.35,19.5902041 C3.35,10.5836735 10.8058333,3.28244898 20.0016667,3.28244898 C29.1925,3.28244898 36.6491667,10.5836735 36.6491667,19.5902041 L36.6491667,19.5902041 Z"></path> </g> <path d="M37.5458333,19.0555102 C37.5458333,28.8457143 29.445,36.7820408 19.455,36.7820408 C9.46,36.7820408 1.3575,28.8457143 1.3575,19.0555102 C1.3575,9.2644898 9.46,1.32816327 19.455,1.32816327 C29.445,1.32816327 37.5458333,9.2644898 37.5458333,19.0555102 L37.5458333,19.0555102 Z" id="Shape" fill="url(#radialGradient-1)"></path> <path d="M36.5833333,19.0555102 C36.5833333,28.3240816 28.9125,35.8359184 19.4541667,35.8359184 C9.99166667,35.8359184 2.31833333,28.324898 2.31833333,19.0555102 C2.31833333,9.7877551 9.99083333,2.27428571 19.4541667,2.27428571 C28.9125,2.27428571 36.5833333,9.7877551 36.5833333,19.0555102 L36.5833333,19.0555102 Z" id="Shape" fill="url(#radialGradient-2)"></path> </g> <path d="M15.4166667,19.0612245 L24.0666667,10.5869388 C24.8316667,9.83918367 24.9866667,8.77714286 24.4141667,8.21469388 C23.8408333,7.65306122 22.7566667,7.80489796 21.9916667,8.55265306 L12.3025,18.0440816 L11.7858333,18.5526531 C11.4966667,18.8318367 11.4966667,19.2889796 11.7858333,19.5697959 C12.0725,19.8506122 12.3025,20.0767347 12.3025,20.0767347 L21.9916667,29.5681633 C22.7566667,30.3142857 23.8416667,30.4677551 24.4141667,29.9061224 C24.9866667,29.3444898 24.8316667,28.2816327 24.0666667,27.5338776 L15.4166667,19.0612245 L15.4166667,19.0612245 Z" id="Shape" fill="#FFFFFF"></path> </g> </g> </g> </svg>'
        right: '<svg width="38px" height="38px" viewBox="0 0 38 38" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"> <defs> <radialGradient cx="25.7596482%" cy="24.9239023%" fx="25.7596482%" fy="24.9239023%" r="84.4165055%" id="radialGradient-1"> <stop stop-color="#8C8C8C" offset="0%"></stop> <stop stop-color="#888888" offset="33.49%"></stop> <stop stop-color="#7D7D7D" offset="64.43%"></stop> <stop stop-color="#6B6B6B" offset="94.27%"></stop> <stop stop-color="#666666" offset="100%"></stop> </radialGradient> <radialGradient cx="72.712136%" cy="76.8143067%" fx="72.712136%" fy="76.8143067%" r="90.8731394%" id="radialGradient-2"> <stop stop-color="#8C8C8C" offset="0%"></stop> <stop stop-color="#888888" offset="33.49%"></stop> <stop stop-color="#7D7D7D" offset="64.43%"></stop> <stop stop-color="#6B6B6B" offset="94.27%"></stop> <stop stop-color="#666666" offset="100%"></stop> </radialGradient> </defs> <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd"> <g id="Group-2" transform="translate(-1.000000, -1.000000)"> <g id="right"> <g id="Group"> <g opacity="0.7" id="Shape" fill="#000000"> <path d="M0.831666667,19.5902041 C0.831666667,29.9461224 9.42833333,38.3697959 20.0016667,38.3697959 C30.57,38.3697959 39.1683333,29.9461224 39.1683333,19.5902041 C39.1683333,9.23591837 30.57,0.813877551 20.0016667,0.813877551 C9.42833333,0.813877551 0.831666667,9.23591837 0.831666667,19.5902041 L0.831666667,19.5902041 Z" opacity="0"></path> <path d="M38.8883333,19.5902041 C38.8883333,29.7959184 30.4166667,38.0955102 20.0016667,38.0955102 C9.58166667,38.0955102 1.11166667,29.7959184 1.11166667,19.5902041 C1.11166667,9.38612245 9.5825,1.08816327 20.0016667,1.08816327 C30.4166667,1.08816327 38.8883333,9.38612245 38.8883333,19.5902041 L38.8883333,19.5902041 Z" opacity="0.1111"></path> <path d="M38.6083333,19.5902041 C38.6083333,29.6457143 30.2633333,37.8212245 20.0016667,37.8212245 C9.735,37.8212245 1.39083333,29.6457143 1.39083333,19.5902041 C1.39083333,9.5355102 9.735,1.36244898 20.0016667,1.36244898 C30.2633333,1.36244898 38.6083333,9.5355102 38.6083333,19.5902041 L38.6083333,19.5902041 Z" opacity="0.2222"></path> <path d="M38.3283333,19.5902041 C38.3283333,29.4971429 30.1116667,37.5469388 20.0016667,37.5469388 C9.88833333,37.5469388 1.67083333,29.4971429 1.67083333,19.5902041 C1.67083333,9.68489796 9.88833333,1.63673469 20.0016667,1.63673469 C30.1116667,1.63673469 38.3283333,9.68489796 38.3283333,19.5902041 L38.3283333,19.5902041 Z" opacity="0.3333"></path> <path d="M38.0483333,19.5902041 C38.0483333,29.3469388 29.9583333,37.2718367 20.0016667,37.2718367 C10.0416667,37.2718367 1.95083333,29.3469388 1.95083333,19.5902041 C1.95083333,9.83510204 10.0416667,1.91102041 20.0016667,1.91102041 C29.9583333,1.91102041 38.0483333,9.83510204 38.0483333,19.5902041 L38.0483333,19.5902041 Z" opacity="0.4444"></path> <path d="M37.7683333,19.5902041 C37.7683333,29.197551 29.805,36.997551 20.0016667,36.997551 C10.1941667,36.997551 2.23083333,29.1967347 2.23083333,19.5902041 C2.23083333,9.9844898 10.195,2.18530612 20.0016667,2.18530612 C29.8058333,2.18530612 37.7683333,9.9844898 37.7683333,19.5902041 L37.7683333,19.5902041 Z" opacity="0.5556"></path> <path d="M37.4883333,19.5902041 C37.4883333,29.0473469 29.6525,36.7232653 20.0016667,36.7232653 C10.3475,36.7232653 2.51,29.0473469 2.51,19.5902041 C2.51,10.1346939 10.3475,2.46040816 20.0016667,2.46040816 C29.6525,2.46040816 37.4883333,10.1346939 37.4883333,19.5902041 L37.4883333,19.5902041 Z" opacity="0.6667"></path> <path d="M37.2083333,19.5902041 C37.2083333,28.8979592 29.5,36.4489796 20.0016667,36.4489796 C10.5008333,36.4489796 2.79,28.8979592 2.79,19.5902041 C2.79,10.2840816 10.5008333,2.73469388 20.0016667,2.73469388 C29.5,2.73469388 37.2083333,10.2840816 37.2083333,19.5902041 L37.2083333,19.5902041 Z" opacity="0.7778"></path> <path d="M36.9283333,19.5902041 C36.9283333,28.7485714 29.3466667,36.1746939 20.0008333,36.1746939 C10.6533333,36.1746939 3.06916667,28.7477551 3.06916667,19.5902041 C3.06916667,10.4334694 10.6541667,3.00816327 20.0008333,3.00816327 C29.3475,3.00897959 36.9283333,10.4334694 36.9283333,19.5902041 L36.9283333,19.5902041 Z" opacity="0.8889"></path> <path d="M36.6491667,19.5902041 C36.6491667,28.5983673 29.195,35.9004082 20.0016667,35.9004082 C10.8075,35.9004082 3.35,28.5983673 3.35,19.5902041 C3.35,10.5836735 10.8075,3.28244898 20.0016667,3.28244898 C29.1941667,3.28244898 36.6491667,10.5836735 36.6491667,19.5902041 L36.6491667,19.5902041 Z"></path> </g> <path d="M37.5475,19.0555102 C37.5475,28.8457143 29.4466667,36.7820408 19.4566667,36.7820408 C9.46166667,36.7820408 1.3575,28.8457143 1.3575,19.0555102 C1.3575,9.2644898 9.46166667,1.32816327 19.4566667,1.32816327 C29.4466667,1.32816327 37.5475,9.2644898 37.5475,19.0555102 L37.5475,19.0555102 Z" id="Shape" fill="url(#radialGradient-1)"></path> <path d="M36.5833333,19.0555102 C36.5833333,28.3240816 28.9125,35.8359184 19.4558333,35.8359184 C9.99333333,35.8359184 2.32,28.324898 2.32,19.0555102 C2.32,9.7877551 9.9925,2.27428571 19.4558333,2.27428571 C28.9125,2.27428571 36.5833333,9.7877551 36.5833333,19.0555102 L36.5833333,19.0555102 Z" id="Shape" fill="url(#radialGradient-2)"></path> </g> <path d="M23.4758333,19.0612245 L14.8258333,27.5338776 C14.0608333,28.2832653 13.9058333,29.3453061 14.4783333,29.9061224 C15.0516667,30.4685714 16.1358333,30.3159184 16.9008333,29.5681633 L26.59,20.0767347 L27.1066667,19.5697959 C27.3958333,19.2889796 27.3958333,18.8334694 27.1066667,18.5526531 C26.82,18.2718367 26.59,18.0440816 26.59,18.0440816 L16.9008333,8.55265306 C16.1358333,7.80653061 15.0508333,7.65306122 14.4783333,8.21469388 C13.905,8.77714286 14.0608333,9.83918367 14.8258333,10.5885714 L23.4758333,19.0612245 L23.4758333,19.0612245 Z" id="Shape" fill="#FFFFFF"></path> </g> </g> </g> </svg>'
        ok: '<svg width="38px" height="38px" viewBox="0 0 38 38" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"> <defs> <radialGradient cx="25.75909%" cy="24.9239023%" fx="25.75909%" fy="24.9239023%" r="84.4177585%" id="radialGradient-1"> <stop stop-color="#8C8C8C" offset="0%"></stop> <stop stop-color="#888888" offset="33.49%"></stop> <stop stop-color="#7D7D7D" offset="64.43%"></stop> <stop stop-color="#6B6B6B" offset="94.27%"></stop> <stop stop-color="#666666" offset="100%"></stop> </radialGradient> <radialGradient cx="72.7127996%" cy="76.8143067%" fx="72.7127996%" fy="76.8143067%" r="90.8709293%" id="radialGradient-2"> <stop stop-color="#8C8C8C" offset="0%"></stop> <stop stop-color="#888888" offset="33.49%"></stop> <stop stop-color="#7D7D7D" offset="64.43%"></stop> <stop stop-color="#6B6B6B" offset="94.27%"></stop> <stop stop-color="#666666" offset="100%"></stop> </radialGradient> </defs> <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd"> <g id="Group-2" transform="translate(-1.000000, -1.000000)"> <g id="ok"> <g id="Group"> <g opacity="0.7" id="Shape" fill="#000000"> <path d="M0.831666667,19.5902041 C0.831666667,29.9461224 9.42833333,38.3697959 20.0016667,38.3697959 C30.57,38.3697959 39.1683333,29.9461224 39.1683333,19.5902041 C39.1683333,9.23591837 30.57,0.813877551 20.0016667,0.813877551 C9.42833333,0.813877551 0.831666667,9.23591837 0.831666667,19.5902041 L0.831666667,19.5902041 Z" opacity="0"></path> <path d="M38.8883333,19.5902041 C38.8883333,29.7959184 30.4166667,38.0955102 20.0016667,38.0955102 C9.58166667,38.0955102 1.11166667,29.7959184 1.11166667,19.5902041 C1.11166667,9.38612245 9.5825,1.08816327 20.0016667,1.08816327 C30.4166667,1.08816327 38.8883333,9.38612245 38.8883333,19.5902041 L38.8883333,19.5902041 Z" opacity="0.1111"></path> <path d="M38.6083333,19.5902041 C38.6083333,29.6457143 30.2633333,37.8212245 20.0016667,37.8212245 C9.735,37.8212245 1.39083333,29.6457143 1.39083333,19.5902041 C1.39083333,9.5355102 9.73416667,1.36244898 20.0016667,1.36244898 C30.2633333,1.36244898 38.6083333,9.5355102 38.6083333,19.5902041 L38.6083333,19.5902041 Z" opacity="0.2222"></path> <path d="M38.3283333,19.5902041 C38.3283333,29.4971429 30.1108333,37.5469388 20.0016667,37.5469388 C9.8875,37.5469388 1.67083333,29.4971429 1.67083333,19.5902041 C1.67083333,9.68489796 9.8875,1.63673469 20.0016667,1.63673469 C30.1108333,1.63673469 38.3283333,9.68489796 38.3283333,19.5902041 L38.3283333,19.5902041 Z" opacity="0.3333"></path> <path d="M38.0483333,19.5902041 C38.0483333,29.3469388 29.9575,37.2718367 20.0016667,37.2718367 C10.0408333,37.2718367 1.95083333,29.3469388 1.95083333,19.5902041 C1.95083333,9.83510204 10.0408333,1.91102041 20.0016667,1.91102041 C29.9575,1.91102041 38.0483333,9.83510204 38.0483333,19.5902041 L38.0483333,19.5902041 Z" opacity="0.4444"></path> <path d="M37.7683333,19.5902041 C37.7683333,29.197551 29.8041667,36.997551 20.0016667,36.997551 C10.1941667,36.997551 2.23083333,29.1967347 2.23083333,19.5902041 C2.23083333,9.9844898 10.1941667,2.18530612 20.0016667,2.18530612 C29.805,2.18530612 37.7683333,9.9844898 37.7683333,19.5902041 L37.7683333,19.5902041 Z" opacity="0.5556"></path> <path d="M37.4883333,19.5902041 C37.4883333,29.0473469 29.6525,36.7232653 20.0016667,36.7232653 C10.3475,36.7232653 2.51,29.0473469 2.51,19.5902041 C2.51,10.1346939 10.3475,2.46040816 20.0016667,2.46040816 C29.6525,2.46040816 37.4883333,10.1346939 37.4883333,19.5902041 L37.4883333,19.5902041 Z" opacity="0.6667"></path> <path d="M37.2083333,19.5902041 C37.2083333,28.8979592 29.4991667,36.4489796 20.0016667,36.4489796 C10.5,36.4489796 2.79,28.8979592 2.79,19.5902041 C2.79,10.2840816 10.5,2.73469388 20.0016667,2.73469388 C29.4991667,2.73469388 37.2083333,10.2840816 37.2083333,19.5902041 L37.2083333,19.5902041 Z" opacity="0.7778"></path> <path d="M36.9283333,19.5902041 C36.9283333,28.7485714 29.3458333,36.1746939 20.0008333,36.1746939 C10.6525,36.1746939 3.06916667,28.7477551 3.06916667,19.5902041 C3.06916667,10.4334694 10.6533333,3.00816327 20.0008333,3.00816327 C29.3466667,3.00897959 36.9283333,10.4334694 36.9283333,19.5902041 L36.9283333,19.5902041 Z" opacity="0.8889"></path> <path d="M36.6491667,19.5902041 C36.6491667,28.5983673 29.1941667,35.9004082 20.0016667,35.9004082 C10.8066667,35.9004082 3.35,28.5983673 3.35,19.5902041 C3.35,10.5836735 10.8066667,3.28244898 20.0016667,3.28244898 C29.1933333,3.28244898 36.6491667,10.5836735 36.6491667,19.5902041 L36.6491667,19.5902041 Z"></path> </g> <path d="M37.5466667,19.0555102 C37.5466667,28.8457143 29.4458333,36.7820408 19.4558333,36.7820408 C9.46083333,36.7820408 1.3575,28.8457143 1.3575,19.0555102 C1.3575,9.2644898 9.46083333,1.32816327 19.4558333,1.32816327 C29.4458333,1.32816327 37.5466667,9.2644898 37.5466667,19.0555102 L37.5466667,19.0555102 Z" id="Shape" fill="url(#radialGradient-1)"></path> <path d="M36.5833333,19.0555102 C36.5833333,28.3240816 28.9125,35.8359184 19.455,35.8359184 C9.9925,35.8359184 2.31916667,28.324898 2.31916667,19.0555102 C2.31916667,9.7877551 9.99166667,2.27428571 19.455,2.27428571 C28.9125,2.27428571 36.5833333,9.7877551 36.5833333,19.0555102 L36.5833333,19.0555102 Z" id="Shape" fill="url(#radialGradient-2)"></path> </g> <g id="Group" transform="translate(5.833333, 12.244898)" fill="#FFFFFF"> <path d="M6.72083333,0.184489796 C8.05333333,0.184489796 9.19583333,0.448979592 10.1508333,0.97877551 C11.1058333,1.50857143 11.8291667,2.25959184 12.32,3.23673469 C12.8108333,4.2122449 13.0566667,5.35755102 13.0566667,6.67428571 C13.0566667,7.64653061 12.9208333,8.53061224 12.6525,9.32653061 C12.385,10.1216327 11.9808333,10.8106122 11.4441667,11.3934694 C10.9066667,11.9779592 10.2466667,12.4244898 9.46416667,12.7338776 C8.68083333,13.042449 7.78416667,13.1967347 6.77416667,13.1967347 C5.76916667,13.1967347 4.86916667,13.037551 4.075,12.72 C3.28,12.402449 2.6175,11.955102 2.08583333,11.3763265 C1.55416667,10.7991837 1.1525,10.1028571 0.880833333,9.29142857 C0.61,8.47836735 0.474166667,7.6 0.474166667,6.6555102 C0.474166667,5.68816327 0.615833333,4.80163265 0.899166667,3.99428571 C1.1825,3.18693878 1.59333333,2.50040816 2.13,1.93469388 C2.66833333,1.36816327 3.32333333,0.933877551 4.09333333,0.634285714 C4.86333333,0.333877551 5.73916667,0.184489796 6.72083333,0.184489796 L6.72083333,0.184489796 Z M10.4183333,6.6555102 C10.4183333,5.73387755 10.2666667,4.93632653 9.9625,4.26040816 C9.65916667,3.58530612 9.225,3.07428571 8.66166667,2.72816327 C8.09666667,2.38204082 7.45083333,2.20816327 6.72083333,2.20816327 C6.20083333,2.20816327 5.72083333,2.3044898 5.28,2.49714286 C4.83916667,2.68816327 4.45916667,2.96653061 4.14083333,3.33306122 C3.8225,3.69877551 3.57083333,4.16653061 3.3875,4.73714286 C3.20333333,5.30530612 3.11166667,5.94530612 3.11166667,6.6555102 C3.11166667,7.37061224 3.20333333,8.01714286 3.3875,8.59510204 C3.57166667,9.17387755 3.83083333,9.65306122 4.1675,10.0334694 C4.50416667,10.4138776 4.88833333,10.6979592 5.325,10.8865306 C5.75916667,11.0759184 6.23666667,11.1714286 6.7575,11.1714286 C7.42333333,11.1714286 8.035,11.0073469 8.59333333,10.6816327 C9.15083333,10.355102 9.59416667,9.85061224 9.925,9.17061224 C10.2533333,8.48897959 10.4183333,7.65061224 10.4183333,6.6555102 L10.4183333,6.6555102 Z" id="Shape"></path> <path d="M17.9,1.72897959 L17.9,6.13959184 L23.0083333,0.921632653 C23.2541667,0.669387755 23.4625,0.484081633 23.6358333,0.363265306 C23.8083333,0.243265306 24.0366667,0.182857143 24.3233333,0.182857143 C24.6966667,0.182857143 24.9991667,0.289795918 25.23,0.505306122 C25.4608333,0.719183673 25.5758333,0.98122449 25.5758333,1.29061224 C25.5758333,1.66204082 25.3808333,2.03183673 24.9891667,2.39755102 L21.8258333,5.33306122 L25.4716667,10.4489796 C25.7283333,10.8040816 25.9208333,11.1142857 26.0483333,11.3804082 C26.1775,11.6457143 26.2416667,11.9053061 26.2416667,12.1567347 C26.2416667,12.437551 26.1283333,12.6808163 25.9041667,12.8865306 C25.68,13.0922449 25.3741667,13.1959184 24.9883333,13.1959184 C24.6258333,13.1959184 24.3316667,13.12 24.1033333,12.9689796 C23.875,12.8179592 23.6825,12.6146939 23.525,12.3640816 C23.3675,12.1118367 23.2275,11.882449 23.1041667,11.677551 L20.03,7.04244898 L17.8991667,9.04163265 L17.8991667,11.642449 C17.8991667,12.1697959 17.7775,12.5591837 17.5325,12.8146939 C17.2866667,13.0693878 16.9708333,13.1967347 16.585,13.1967347 C16.3625,13.1967347 16.1508333,13.1395918 15.9458333,13.0253061 C15.7408333,12.9110204 15.5833333,12.7567347 15.4725,12.562449 C15.3908333,12.4016327 15.3408333,12.2155102 15.3233333,12.0032653 C15.3058333,11.7918367 15.2975,11.4857143 15.2975,11.084898 L15.2975,1.72979592 C15.2975,1.21469388 15.4133333,0.828571429 15.6433333,0.570612245 C15.8741667,0.313469388 16.1883333,0.184489796 16.585,0.184489796 C16.9775,0.184489796 17.2941667,0.311836735 17.5366667,0.565714286 C17.78,0.82122449 17.9,1.20816327 17.9,1.72897959 L17.9,1.72897959 Z" id="Shape"></path> </g> </g> </g> </g> </svg>'
        check: '<svg width="30px" height="30px" viewBox="0 0 30 30" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"> <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd"> <g id="Group-2" transform="translate(-5.000000, -5.000000)"> <g id="check" transform="translate(5.000000, 5.000000)"> <rect id="Rectangle-path" fill="#009640" x="0.3125" y="0.204081633" width="29.375" height="28.9795918"></rect> <path d="M27.0758333,5.91918367 C26.4183333,5.27673469 25.1716667,5.45142857 24.2958333,6.30938776 L10.7975,19.5297959 L5.70416667,14.5387755 C4.82583333,13.6808163 3.58166667,13.5044898 2.92416667,14.1485714 C2.26666667,14.7942857 2.44416667,16.0130612 3.32,16.8726531 L9.60583333,23.0310204 C9.60583333,23.0310204 9.875,23.2922449 10.2041667,23.6146939 C10.5333333,23.9371429 11.0666667,23.9371429 11.3966667,23.6146939 L11.9908333,23.0310204 L26.6783333,8.64163265 C27.555,7.78367347 27.7333333,6.56489796 27.0758333,5.91918367 L27.0758333,5.91918367 Z" id="Shape" fill="#FFFFFF"></path> </g> </g> </g> </svg>'
        space: '<svg width="60px" height="20px" viewBox="0 0 60 20" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"> <g id="space" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd"> <path d="M58.9485418,0 L58.9485418,18.179702 L1.05047458,18.179702 L1.05047458,0 L0,0 L0,19.2301766 L60,19.2301766 L60,0 L58.9485418,0 Z" id="Shape" fill="#4d4944"></path> </g> </svg>'

    LETTERS = [
        {key:'A', value:'A'},
        {key:'B', value:'B'},
        {key:'C', value:'C'},
        {key:'D', value:'D'},
        {key:'E', value:'E'},
        {key:'F', value:'F'},
        {key:'G', value:'G'},
        {key:'H', value:'H'},
        {key:'I', value:'I'},
        {key:'J', value:'J'},
        {key:'K', value:'K'},
        {key:'L', value:'L'},
        {key:'M', value:'M'},
        {key:'N', value:'N'},
        {key:'O', value:'O'},
        {key:'P', value:'P'},
        {key:'Q', value:'Q'},
        {key:'R', value:'R'},
        {key:'S', value:'S'},
        {key:'T', value:'T'},
        {key:'U', value:'U'},
        {key:'V', value:'V'},
        {key:'W', value:'W'},
        {key:'X', value:'X'},
        {key:'Y', value:'Y'},
        {key:'Z', value:'Z'},
        {key:' ', value:'&nbsp;'},
        {key:'0', value:'0'},
        {key:'1', value:'1'},
        {key:'2', value:'2'},
        {key:'3', value:'3'},
        {key:'4', value:'4'},
        {key:'5', value:'5'},
        {key:'6', value:'6'},
        {key:'7', value:'7'},
        {key:'8', value:'8'},
        {key:'9', value:'9'},
        {key:LETTER_BACKSPACE, value:SVG.delete},
        {key:LETTER_ENTER, value:SVG.check},
    ]
            
    _options = undefined
    time = undefined
    rank = undefined
    name = undefined
    layout = undefined

    # --- utils

    format_results = (data) ->
        answers = data.answers.map (i) ->
            "#{ i.id }:#{ i.answer }"
        out =
            category: data.category.id
            name: null
            time: data.time
            answers: answers.join(',')

    # --- models & collections

    Time = Backbone.Model.extend
        defaults:
            time: undefined

    Rank = Backbone.Model.extend
        defaults:
            position: undefined
            total: undefined
            top: undefined
        initialize: (attributes, options) ->
            @url = "/api/results/#{ options.difficulty }-#{ options.category }/#{ options.time }/#{ options.correct }"

    Name = Backbone.Model.extend
        defaults:
            name: ''
            letter: 'A'

    Score = Backbone.Model.extend
        defaults:
            name: undefined
            time: undefined
            category: undefined
            difficulty: undefined
            questions: undefined
        url: '/api/score'

    # --- views

    InfoView = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <h1><img src='<%= icon %>'><%= category %></h1>
                <h2><%= difficulty %></h2>
            """)(serialized_model)

    GreatTimeView = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("<%= show_time() %>")(serialized_model)
        templateHelpers: ->
            show_time: ->
                display_elapsed(@time)

    BadTimeView = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("<%= show_time() %>")(serialized_model)
        templateHelpers: ->
            show_time: ->
                display_elapsed(@time)
        initialize: () ->
            window.channel.on 'keypress', (msg) ->
                window.channel.trigger('result:save', null)
        onDestroy: () ->
            window.channel.off('keypress')

    TypewriterView1 = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("""
                <table><tr><%= show_name() %><td class="selected"><%= show_letter() %></td><%= show_empty() %></tr></table>
            """)(serialized_model)
        templateHelpers: ->
            show_letter: ->
                x = _.filter LETTERS, (i) =>
                    i.key == @letter
                x[0].value
            show_name: ->
                out = ""
                for i in [0...@name.length]
                    out += "<td>#{ @name.charAt(i) }</td>"
                out
            show_empty: ->
                rest = NAME_MAX_LENGTH - @name.length
                out = ""
                if rest > 1
                    for i in [1...rest]
                        out += "<td class='empty'>#{SVG.space}</td>"
                out
        initialize: () ->
            that = @
            @model.on 'change', () ->
                that.render()

            window.channel.on 'key', (msg) ->
                clear_delay()

                if msg == 'fire'
                    window.sfx.button2.play()
                    letter = that.model.get('letter')
                    _name = that.model.get('name')

                    if letter == LETTER_BACKSPACE
                        if _name.length > 0
                            that.model.set('name', _name.substring(0, _name.length - 1))
                    else if letter == LETTER_ENTER
                        if _name.length > 0
                            window.channel.trigger('result:save', _name)
                            return
                    else if _name.length < NAME_MAX_LENGTH - 1
                        that.model.set('name', "#{ _name }#{ letter }")
                        _name = that.model.get('name')

                set_delay(handler, _options.options.IDLE_RESULT)

        onDestroy: () ->
            window.channel.off('key')
            @model.off('change')


    TypewriterView2 = Marionette.ItemView.extend
        template: (serialized_model) ->
            _.template("<table><tr><%= show_alphabet() %></tr></table>")(serialized_model)
        templateHelpers: ->
            show_alphabet: ->
                letter = @letter
                out = ("<td#{ if LETTERS[i].key == letter then ' class=\"selected\"' else '' }>#{LETTERS[i].value}</td>" for i in [0...LETTERS.length])
                out.join('')
        initialize: () ->
            that = @
            @model.on 'change', () ->
                that.render()

            window.channel.on 'key', (msg) ->
                clear_delay()

                letter = that.model.get('letter')
                _temp = LETTERS.map (i) ->
                    i.key == letter
                index = _temp.indexOf(true)

                if msg == 'left' and index > 0
                    window.sfx.button.play()
                    index -= 1
                    that.model.set('letter', LETTERS[index].key)
                else if msg == 'right' and index < (LETTERS.length - 1)
                    window.sfx.button.play()
                    index += 1
                    that.model.set('letter', LETTERS[index].key)

                set_delay(handler, _options.options.IDLE_RESULT)

        onDestroy: () ->
            window.channel.off('key')
            @model.off('change')


    GoodScreenLayout = Marionette.LayoutView.extend
        template: _.template """
            <div id="header"></div>
            <div id="body">
                <table class="result good-result">
                    <tr class="row-1">
                        <td colspan="2">
                            <h1>#{SVG.rekord}Nový rekord!</h1>
                            <h2></h2>
                            <p>Tvůj čas se dostal do žebříčku. Zadej jméno svého týmu.</p>
                        </td>
                    </tr>
                    <tr class="row-2">
                        <td class="typewriter"></td>
                        <td class="help" rowspan="2">
                            <table>
                                <tr>
                                    <td>#{SVG.left}&nbsp;#{SVG.right}</td>
                                    <td><p>Výběr znaku</p></td>
                                </tr>
                                <tr>
                                    <td>#{SVG.ok}</td>
                                    <td><p>Potvrzení výběru</p></td>
                                </tr>
                                <tr>
                                    <td>#{SVG.delete}</td>
                                    <td><p>Mazání znaku</p></td>
                                </tr>
                                <tr>
                                    <td>#{SVG.check}</td>
                                    <td><p>Uložení jména</p></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr class="row-3">
                        <td colspan="2"></td>
                    </tr>
                    <tr class="row-4">
                        <td colspan="2"><p>Délka jména maximálně #{NAME_MAX_LENGTH-1} znaků</p></td>
                    </tr>
                </table>
            </div>
        """

        onRender: () ->
            $('body').attr('class', 'layout-a');

        regions:
            info: '#header'
            time: '#body .row-1 h2'
            input: '.row-2 .typewriter'
            alphabet: '.row-3 td'

    BadScreenLayout = Marionette.LayoutView.extend
        template: _.template """
            <div id="header"></div>
            <div id="body">
                <table class="result bad-result">
                    <tr class="row-1">
                        <td>
                            <h1><img src="svg/rekord.svg" />Dosažený čas</h1>
                            <h2></h2>
                        </td>
                    </tr>
                </table>
            </div>
        """

        onRender: () ->
            $('body').attr('class', 'layout-a');

        regions:
            info: '#header'
            time: '#body .row-1 h2'

    # --- timer handler

    handler = () ->
        _name = name.get('name')
        if _name.length < 1
            _name = null
        window.channel.trigger('result:save', _name)

    # --- module

    Mod.onStart = (options) ->
        console.log 'Result module'
        console.log options
        _options = options
        window.sfx.surprise.play()

        # put results data into models
        time = new Time({time: options.time})
        correct = _.filter options.answers, (i) ->
            i.answer
        name = new Name()
        rank = new Rank null, 
            difficulty: options.gamemode.difficulty
            category: options.gamemode.category
            time: options.time
            correct: correct.length
        rank.fetch()
            
        # save results to server
        window.channel.on 'result:save', (_name) ->
            clear_delay()
            questions = _.map _options.answers, (i) ->
                {question: i.id, correct: i.answer}
            score = new Score
                name: _name
                time: _options.time
                category: _options.gamemode.category
                difficulty: _options.gamemode.difficulty
                questions: questions
                top: if _name then true else false
            score.save()
            score.on 'sync', () ->
                window.channel.trigger('result:close', _options)
                score.off('sync')

        # get rank of player score from server
        rank.on 'sync', () ->
            if rank.get('top')
                # render basic layout
                layout = new GoodScreenLayout
                    el: make_content_wrapper()
                layout.render()
                layout.getRegion('info').show(new InfoView({model: new Backbone.Model({'category': options.gamemode.title, 'icon': options.gamemode.category_icon, 'difficulty': options.gamemode.difficulty_title})}))

                layout.getRegion('time').show(new GreatTimeView({model: time}))
                layout.getRegion('input').show(new TypewriterView1({model: name}))
                layout.getRegion('alphabet').show(new TypewriterView2({model: name}))
            else
                # render basic layout
                layout = new BadScreenLayout
                    el: make_content_wrapper()
                layout.render()
                layout.getRegion('info').show(new InfoView({model: new Backbone.Model({'category': options.gamemode.title, 'icon': options.gamemode.category_icon, 'difficulty': options.gamemode.difficulty_title})}))

                layout.getRegion('time').show(new BadTimeView({model: time}))

        set_delay(handler, _options.options.IDLE_RESULT)


    Mod.onStop = () ->
        clear_delay()
        time = undefined
        rank.off('sync')
        rank = undefined
        score = undefined
        layout.destroy()
        window.channel.off('result:save')
