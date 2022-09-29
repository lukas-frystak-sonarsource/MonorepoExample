using MathLibrary;
using NUnit.Framework;

namespace MathLibraryTests
{
    public class BasicMathTests
    {

        [TestCase(1, 2, 3)]
        [TestCase(10, 23, 33)]
        public void Add_ShouldEvaluateCorrectly(int a, int b, int expectedResult)
        {
            // Actual result
            int actualResult = BasicMath.Add(a, b);

            // Assert
            Assert.AreEqual(expectedResult, actualResult);
        }
    }
}