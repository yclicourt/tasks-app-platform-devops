import { useEffect } from "react";

import { useForm } from "react-hook-form";
import { createTask, deleteTask, updateTask, getTask } from "../api/tasks.api";
import { useNavigate, useParams } from "react-router-dom";
import { toast } from "react-hot-toast";

export function TaskFormPage() {
  const {
    register,
    handleSubmit,
    formState: { errors },
    setValue,
  } = useForm();
  const navigate = useNavigate();
  const params = useParams();

  const onSubmit = handleSubmit(async (data) => {
    try {
      if (params.id) {
        await updateTask(params.id, data);
        toast.success("Tarea actualizada", {
          position: "bottom-right",
          style: {
            background: "#101010",
            color: "#fff",
          },
        });
      } else {
        await createTask(data);
        toast.success("Tarea creada", {
          position: "bottom-right",
          style: {
            background: "#101010",
            color: "#fff",
          },
        });
      }
      navigate("/tasks");
    } catch (error) {
      console.error("Error en el servidor:", error);
      toast.error("Error al conectar con el backend");
    }
  });

  useEffect(() => {
    async function loadTask() {
      if (params.id) {
        const { data } = await getTask(params.id);
        setValue("title", data.title);
        setValue("description", data.description);
      }
    }
    loadTask();
  }, [params.id, setValue]);

  return (
    <div className="max-w-xl mx-auto">
      <form onSubmit={onSubmit}>
        <input
          type="text"
          placeholder="title"
          {...register("title", { required: true })}
          className="bg-zinc-700 p-3 rounded-lg block w-full mb-3"
        />
        {errors.title && <span>title is required</span>}
        <textarea
          rows="3"
          placeholder="Description"
          {...register("description", { required: true })}
          className="bg-zinc-700 p3 rounded-lg block w-full mb-3"
        ></textarea>
        {errors.description && <span>description is required</span>}
        <button type="submit" className="bg-indigo-500 p-3 rounded-lg block w-full mt-3">
          Save
        </button>
      </form>
      {params.id && (
        <div className="flex justify-end">
          <button
            type="button"
            className="bg-red-500 p-3 rounded-lg w-48 mt-3"
            onClick={async () => {
              const accepted = window.confirm("are you sure?");
              if (accepted) {
                try {
                  await deleteTask(params.id);
                  toast.success("Tarea eliminada", {
                    position: "bottom-right",
                    style: {
                      background: "#101010",
                      color: "#fff",
                    },
                  });
                  navigate("/tasks");
                } catch (error) {
                  console.error("Error al eliminar:", error);
                  toast.error("No se pudo eliminar la tarea");
                }
              }
            }}
          >
            Delete
          </button>
        </div>
      )}
    </div>
  );
}
