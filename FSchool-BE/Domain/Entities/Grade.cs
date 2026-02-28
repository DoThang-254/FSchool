
namespace Domain.Entities
{
    public class Grade
    {
        [Key]
        public int Id { get; set; }

        public double Score { get; set; }

        [MaxLength(20)]
        public string Status { get; set; } // Passed, Failed

        // Foreign Keys
        public int StudentId { get; set; }
        [ForeignKey("StudentId")]
        public Student Student { get; set; }

        public int SubjectId { get; set; }
        [ForeignKey("SubjectId")]
        public Subject Subject { get; set; }

        public int SemesterId { get; set; }
        [ForeignKey("SemesterId")]
        public Semester Semester { get; set; }
    }
}