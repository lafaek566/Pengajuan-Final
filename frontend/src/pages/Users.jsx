import { useEffect, useState } from "react";
import axios from "axios";

export default function Users() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    axios.get("http://localhost:5009/api/users").then((res) => {
      setUsers(res.data);
    });
  }, []);

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Manajemen Pengguna</h1>
      <table className="w-full border text-left">
        <thead className="bg-gray-100">
          <tr>
            <th className="border px-4 py-2">ID</th>
            <th className="border px-4 py-2">Nama</th>
            <th className="border px-4 py-2">Email</th>
            <th className="border px-4 py-2">Level</th>
          </tr>
        </thead>
        <tbody>
          {users.map((u) => (
            <tr key={u.id_users}>
              <td className="border px-4 py-2">{u.id_users}</td>
              <td className="border px-4 py-2">{u.username}</td>
              <td className="border px-4 py-2">{u.email}</td>
              <td className="border px-4 py-2">{u.level}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
