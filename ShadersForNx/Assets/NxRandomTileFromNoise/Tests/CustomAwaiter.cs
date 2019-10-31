using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomAwaiter : MonoBehaviour
{
    private async void WaitABit()
    {
        await System.Threading.Tasks.Task.Yield();
    }

    private void waitForAction()
    {
        
    }
    private async System.Threading.Tasks.Task<CustomAwaiter> waitForActionStart()
    {
        var waiter = await WaitABit2();
        // Task.WhenAny();
        // return x.Result;   
        return waiter;
    }

    private async System.Threading.Tasks.Task<CustomAwaiter> WaitABit2()
    {
        await System.Threading.Tasks.Task.Yield();
        return this;
    }
}
