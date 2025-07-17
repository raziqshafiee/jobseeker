// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyDreznbSPyOFi35R7vP6lyolvNI_lEWdPo",
  authDomain: "jobseeker-655c1.firebaseapp.com",
  projectId: "jobseeker-655c1",
  storageBucket: "jobseeker-655c1.firebasestorage.app",
  messagingSenderId: "685942696547",
  appId: "1:685942696547:web:088e5ce6d4886b0020a656",
  measurementId: "G-1C7PERBMPX"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);