# automates making random test cases for matrix int8 matrix mult
# txt files generated used in top_systolic_tb.sv

import numpy as np
from golden_model import golden_model

ARRAY_SIZE = 2
NUM_TESTS = 10
# [low, hig)
# int8 ~ [-128, 128)

rng = np.random.default_rng(seed=1234)

with open("A_vectors.txt", "w") as f_A, \
     open("B_vectors.txt", "w") as f_B, \
     open("C_vectors.txt", "w") as f_C:
    
    for i in range(NUM_TESTS):

        A = rng.integers(
            -128,
            128,
            size=(ARRAY_SIZE, ARRAY_SIZE),
            dtype=np.int8
        )

        B = rng.integers(
            -128,
            128,
            size=(ARRAY_SIZE, ARRAY_SIZE),
            dtype=np.int8
        )

        C = golden_model(A, B)

        f_A.write(" ".join(map(str, A.flatten())) + "\n")
        f_B.write(" ".join(map(str, B.flatten())) + "\n")
        f_C.write(" ".join(map(str, C.flatten())) + "\n")
    