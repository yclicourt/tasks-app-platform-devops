import axios from "axios";

const API_URL =
  window.APP_CONFIG?.API_URL || import.meta.env.VITE_API_URL_PLACEHOLDER;

const tasksApi = axios.create({
  baseURL: API_URL,
});

export const getAllTasks = () => tasksApi.get("");
export const getTask = (id) => tasksApi.get(`${id}/`);
export const createTask = (task) => tasksApi.post("", task);
export const deleteTask = (id) => tasksApi.delete(`${id}/`);
export const updateTask = (id, task) => tasksApi.put(`${id}/`, task);
