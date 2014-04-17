#!/usr/bin/python

from pymongo import MongoClient
import tornado.web

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options

from basehandler import BaseHandler

from sklearn import svm
from sklearn.neighbors import KNeighborsClassifier
import pickle
from bson.binary import Binary
import json

class UploadLabeledDatapointHandler(BaseHandler):
	def post(self):
		'''Save data point and class label to database
		'''
		data = json.loads(self.request.body)

		vals = data['feature'];
		fvals = [float(val) for val in vals];
		label = data['label'];
		sess  = data['dsid']

		dbid = self.db.labeledinstances.insert(
			{"feature":fvals,"label":label,"dsid":sess}
			);
		self.write_json({"id":str(dbid),"feature":fvals,"label":label});
		self.client.close()

class RequestNewDatasetId(BaseHandler):
	def get(self):
		'''Get a new dataset ID for building a new dataset
		'''
		a = self.db.labeledinstances.find_one(sort=[("dsid", -1)])
		newSessionId = float(a['dsid'])+1;
		self.write_json({"dsid":newSessionId})
		self.client.close()

class UpdateModelForDatasetId(BaseHandler):
	def get(self):
		'''Train a new model (or update) for given dataset ID
		'''
		dsid = self.get_int_arg("dsid",default=0);

		# create feature vectors from database
		f=[];
		for a in self.db.labeledinstances.find({"dsid":dsid}):
			f.append([float(val) for val in a['feature']])

		# create label vector from database
		l=[];
		for a in self.db.labeledinstances.find({"dsid":dsid}):
			l.append(a['label'])

		# fit the model to the data
		c_knn = KNeighborsClassifier(n_neighbors=3);

		C=1.0
		c_svm=svm.SVC(kernel='linear', C=C)

		acc_knn = -1
		acc_svm = -1
		
		if l:
			c_knn.fit(f,l); # training
			lstar_knn = c_knn.predict(f);
			acc_knn = sum(lstar_knn==l)/float(len(l));
			bytes_knn = pickle.dumps(c_knn);

			c_svm.fit(f,l); # training
			lstar_svm = c_svm.predict(f);
			acc_svm = sum(lstar_svm==l)/float(len(l));
			bytes_svm = pickle.dumps(c_svm);

			self.db.models.update({"dsid":dsid},
				{  "$set": {"model_knn":Binary(bytes_knn), "model_svm":Binary(bytes_svm}  },
				upsert=True)

		# send back the resubstitution accuracy
		# if training takes a while, we are blocking tornado!! No!!
		self.write_json({"resubAccuracy_knn":acc_knn, "resubAccuracy_svm":acc_svm})
		self.client.close()
		

class PredictOneFromDatasetId(BaseHandler):
	def post(self):
		'''Predict the class of a sent feature vector
		'''
		data = json.loads(self.request.body)

		vals = data['feature'];
		fvals = [float(val) for val in vals];
		dsid  = data['dsid']
		model = data['model']

		# load the model from the database (using pickle)
		# we are blocking tornado!! no!!
		tmp = self.db.models.find_one({"dsid":dsid})
		
		if model == 'svm':
			c2 = pickle.loads(tmp['model_svm'])
		else
			c2 = pickle.loads(tep['model_knn'])

		predLabel = c2.predict(fvals);
		self.write_json({"prediction":str(predLabel)})
		self.client.close()


class GetLabelList(BaseHandler):
	def get(self):
		dsid = self.get_int_arg("dsid",default=0);

		l=set();
		for a in self.db.labeledinstances.find({"dsid":dsid}):
			l.add(a['label'])

		self.write_json({"labels":list(l)})
