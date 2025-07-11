import React, { useRef } from "react";
import jsPDF from "jspdf";
import html2canvas from "html2canvas";

const CetakPdf = ({ data }) => {
  const printRef = useRef();

  const handleDownloadPDF = async () => {
    const element = printRef.current;
    const canvas = await html2canvas(element, { scale: 2 });
    const imageData = canvas.toDataURL("image/png");

    const pdf = new jsPDF("p", "mm", "a4");
    const imgProps = pdf.getImageProperties(imageData);
    const pdfWidth = pdf.internal.pageSize.getWidth();
    const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;

    pdf.addImage(imageData, "PNG", 0, 0, pdfWidth, pdfHeight);

    const filename = `proposal-${data.nim || "unknown"}.pdf`;
    pdf.save(filename);
  };

  const formatTanggal = (tgl) => {
    if (!tgl) return "-";
    const date = new Date(tgl);
    return (
      date.toLocaleString("id-ID", {
        weekday: "long",
        day: "2-digit",
        month: "long",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      }) + " WIB"
    );
  };

  const statusText = (s) => {
    if (s === "Y") return "✅ Disetujui";
    if (s === "T") return "❌ Ditolak";
    return "⌛ Belum Diproses";
  };

  const getWatermarkText = (s) => {
    if (s === "Y") return "IKUT SIDANG";
    if (s === "T") return "DITOLAK";
    return "";
  };

  const getWatermarkStyle = (s) => {
    if (s === "Y") return "text-green-200";
    if (s === "T") return "text-red-200";
    return "text-gray-300";
  };

  if (!data) return null;

  return (
    <div className="mt-6">
      <h2 className="text-xl font-bold mb-4">Cetak Bukti Proposal</h2>

      <div
        ref={printRef}
        className="relative border p-4 bg-white text-sm space-y-2 leading-relaxed overflow-hidden"
      >
        {/* Watermark */}
        {["Y", "T"].includes(data.status_persetujuan) && (
          <div
            className={`absolute inset-0 flex items-center justify-center pointer-events-none opacity-50 font-extrabold text-[80px] rotate-[-30deg] ${getWatermarkStyle(
              data.status_persetujuan
            )}`}
          >
            {getWatermarkText(data.status_persetujuan)}
          </div>
        )}

        <h3 className="text-lg font-semibold mb-2 text-center z-10 relative">
          Bukti Pendaftaran Proposal Tugas Akhir
        </h3>

        <div className="z-10 relative space-y-1">
          <p>
            <strong>Nama:</strong> {data.nama_mahasiswa || "-"}
          </p>
          <p>
            <strong>NIM:</strong> {data.nim || "-"}
          </p>
          <p>
            <strong>Prodi:</strong> {data.nama_prodi || "-"}
          </p>
          <p>
            <strong>Judul:</strong> {data.judul_ta}
          </p>
          <p>
            <strong>Topik:</strong> {data.nama_topik || "-"}
          </p>
          <p>
            <strong>Dosen Pembimbing:</strong> {data.nama_pembimbing}
          </p>
          <p>
            <strong>Penguji 1:</strong> {data.nama_penguji || "-"}
          </p>
          <p>
            <strong>Penguji 2:</strong> {data.nama_penguji2 || "-"}
          </p>
          <p>
            <strong>Status Proposal:</strong>{" "}
            {statusText(data.status_persetujuan)}
          </p>
          <p>
            <strong>Tanggal Ujian:</strong> {formatTanggal(data.tgl_ujian)}
          </p>
        </div>
      </div>

      <button
        onClick={handleDownloadPDF}
        className="mt-4 bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700"
      >
        Download PDF
      </button>
    </div>
  );
};

export default CetakPdf;
