#!/usr/bin/env python
from __future__ import print_function
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.lines as mlines
from tkinter import TclError
import argparse

# Adding commandline argument for custom datasets
parser = argparse.ArgumentParser(description="160552's solution for Q2 of "\
                                             "CS251A Assignment 3")
parser.add_argument('--train', metavar='', type=str,
                    help='path to csv file containing training data')
parser.add_argument('--test', metavar='', type=str,
                    help='path to csv file containing test data')
args = parser.parse_args()
if args.train:
    training_csv = args.train
else:
    training_csv = 'train.csv'
if args.test:
    test_csv = args.test
else:
    test_csv = 'test.csv'

# Import training data CSV
X_train, y_train = np.loadtxt(open(training_csv, 'r'), skiprows=1,
                                    delimiter=',').transpose()
X_train = np.c_[np.ones(X_train.shape), X_train]    # Add 1s column

# Pyplot legends
red_points = mlines.Line2D([], [], color='red', marker='.', markersize=10,
                            label='y_train')
blue_line = mlines.Line2D([], [], color='blue', label='predictions')
def plotter(predictions=None, title=None, pause_time=2, clear=True):
    if clear:
        plt.clf()
        plt.xlabel('X')
        plt.ylabel('Y')
        plt.legend(handles=[red_points, blue_line])
        plt.plot(X_train[:,1], y_train, 'r,')

    if title:
        plt.title(title)
    if predictions is not None:
        plt.plot(X_train[:,1], predictions, 'blue')
    try:
        plt.pause(pause_time)
    except TclError:
        pass

# Random initialization
w = np.random.rand(2,)

# Results with initialized values
plotter(np.matmul(w, X_train.transpose()), "Results of random initialization")

# Direct method
w_direct = np.matmul(np.matmul(np.linalg.inv(np.matmul(X_train.transpose(),
    X_train)), X_train.transpose()), y_train)

# Results of direct method
plotter(np.matmul(w_direct, X_train.transpose()), "Results of direct method")

# Hyperparameters
learn_rate = 1e-8
num_epochs = 1

# Training
plotter(pause_time=1e-5)
for epoch in range(num_epochs):
    for j, (point, pred) in enumerate(zip(X_train, y_train)):
        w -= learn_rate * (np.matmul(w, point) - pred) * point  # SGD update
        if j % 100 == 0:    # Plotting progress
            plotter(np.matmul(w, X_train.transpose()), "Training...", 1e-5,
                    False)
plotter(title="Training done", clear=False)

# Results of SGD
plotter(np.matmul(w, X_train.transpose()), "Results of SGD")
plt.close()

# Import test data CSV
X_test, y_test = np.loadtxt(open(test_csv, 'r'), skiprows=1,
                                    delimiter=',').transpose()
X_test = np.c_[np.ones(X_test.shape), X_test]   # Add 1s column

# Testing
y_pred1 = np.matmul(w, X_test.transpose())  # SGD predictions
print("RMSE for SGD: ", np.linalg.norm(y_pred1 - y_test) / np.sqrt(
    len(y_test)))
y_pred2 = np.matmul(w_direct, X_test.transpose())   # Direct method predictions
print("RMSE for direct method: ", np.linalg.norm(y_pred2 - y_test) / np.sqrt(
    len(y_test)))
