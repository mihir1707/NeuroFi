import jwt from "jsonwebtoken";
import { JWT_SECRET, JWT_EXPIRES_IN } from "../config/constants.js";

export const generateToken = (user) => {
  const payload = {
    id: user._id.toString(),    
    email: user.email,          
    name: user.name,            
  };

  return jwt.sign(payload, JWT_SECRET, {
    expiresIn: JWT_EXPIRES_IN,  
    algorithm: "HS256",         
  });
};


export const verifyToken = (token) => {
  return jwt.verify(token, JWT_SECRET, {
    algorithms: ["HS256"],
  });
};

export const decodeToken = (token) => {
  return jwt.decode(token);
};
