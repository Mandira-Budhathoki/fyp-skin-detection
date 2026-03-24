import traceback
import sys
sys.path.append('c:/fyp/backend')
from melanoma_analyzer import MelanomaAnalyzer

try:
    m = MelanomaAnalyzer()
    print("Model Loaded:", m.model is not None)
except BaseException as e:
    traceback.print_exc()
