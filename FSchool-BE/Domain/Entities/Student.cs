namespace Domain.Entities
{
    public class Student
    {
        [Key]
        public int Id { get; set; }

        [Required, MaxLength(100)]
        public string FullName { get; set; }

        [Required, MaxLength(20)]
        public string RollNumber { get; set; }

        public string AvatarUrl { get; set; }

        // Foreign Keys
        public int AccountId { get; set; }
        [ForeignKey("AccountId")]
        public Account Account { get; set; }

        
        public ICollection<SchoolClass> SchoolClasses { get; set; }

        public ICollection<Grade> Grades { get; set; }
        public ICollection<AbsenceRequest> AbsenceRequests { get; set; }
        public ICollection<Attendance> Attendances { get; set; }

        public ICollection<Club> Clubs { get; set; }

    }
}
